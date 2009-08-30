#!/usr/bin/env ruby

# gary: a linker with configurable target addresses
# (Gary Linker. Sorry.)

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}"

require 'object_file'
require 'library_file'
require 'infix_expression'
require 'memory_map'

$modules_by_name = {}
$top_level_module_names = []
$address_restrictions = []
$org_address = nil # lowest explicit org address seen; used as the lower end of the default address range unless overridden
$default_address_range = nil

def register_module(mod)
	$modules_by_name[mod.name] = mod
	if (mod.org_address != 0xffff)
		$address_restrictions << [mod.name, (mod.org_address .. mod.org_address)]
		$org_address = mod.org_address unless $org_address and $org_address < mod.org_address
	end
	for name_decl in mod.name_declarations
		$modules_by_name[name_decl.name] = mod
	end
end

def lib(*filenames)
	for filename in filenames
		library_file = LibraryFile.read(File.open(filename))
		for mod in library_file
			register_module(mod)
		end
	end
end

def obj(*filenames)
	for filename in filenames
		mod = ObjectFile.read(File.open(filename))
		register_module(mod)
	end
end

def default_range(range)
	$default_address_range = range
end

def build(mod_name)
	$top_level_module_names << mod_name.upcase
end

def restrict(mod_name, address_range)
	mod_name.upcase!
	mod_length = $modules_by_name[mod_name].code.size
	unless $address_restrictions.find{|r| r.first == mod_name}
		$address_restrictions << [mod_name, (address_range.min .. (address_range.max - mod_length + 1))]
	end
end

load ARGV[0]

# Walk library dependencies to generate a list of modules that we need to allocate
modules_to_scan = $top_level_module_names.collect{|name| $modules_by_name[name] or raise "Could not find module named #{name} for building" }

modules_to_allocate = []

while mod = modules_to_scan.shift
	modules_to_allocate << mod
	for dependency_name in mod.library_name_declarations
		dependency = $modules_by_name[dependency_name] or raise "Could not find module named #{dependency_name}, required by #{mod.name}"
		next if modules_to_allocate.find {|m| m.name == dependency.name} or modules_to_scan.find {|m| m.name == dependency.name}
		modules_to_scan << dependency
	end
end

# Allocate module start addresses, starting with the ones with most restrictive address restrictions
module_addresses = {}
mm = MemoryMap.new
$address_restrictions.sort_by{|name, range| range.max - range.min}.each do |name, range|
	size = $modules_by_name[name].code.size
	addr = mm.allocate(range, size)
	raise "could not allocate address for #{name}" if addr.nil?
	module_addresses[name] = addr
end
# now allocate the rest of the modules, which have no address restrictions beyond the default
$default_address_range ||= (($org_address || 0x8000) .. 0xffff)
modules_to_allocate.each do |mod|
	next if module_addresses.has_key?(mod.name)
	size = mod.code.size
	addr = mm.allocate($default_address_range, size)
	raise "could not allocate address for #{name}" if addr.nil?
	module_addresses[mod.name] = addr
end

def import_symbol(symbol, base_address, symbols, lib_name)
	if symbol.type == 'C' # constant
		symbols[symbol.name] = symbol.value
	elsif symbol.type == 'A' # relocatable address
		symbols[symbol.name] = symbol.value + base_address
	else
		raise "Unknown symbol type '#{symbol.type}' for symbol #{symbol.name} in module #{lib_name}"
	end
end

mem = "\0" * 0x10000
first_addr = 0xffff
last_addr = 0x0000 # last plus one really

for mod in modules_to_allocate
	# generate the list of symbols required to compile this module
	symbols = {}
	# import global symbols from external libraries first
	for lib_name in mod.library_name_declarations
		lib = $modules_by_name[lib_name]
		for symbol in lib.name_declarations
			next unless symbol.scope == 'G' or symbol.scope == 'X' # consider global / library scope definitions only
			import_symbol(symbol, module_addresses[lib.name], symbols, lib.name)
		end
	end
	base_address = module_addresses[mod.name]
	first_addr = base_address if base_address < first_addr
	size = mod.code.size
	last_addr = base_address + size if base_address + size > last_addr
	# and now add the symbols from the local file
	for symbol in mod.name_declarations
		import_symbol(symbol, base_address, symbols, mod.name)
	end
	
	mem[base_address ... base_address + size] = mod.code
	
	# now perform expression substitution
	for expr in mod.expression_declarations
		value = InfixExpression.evaluate(expr.expression, symbols)
		case expr.type
			when 'U', 'S'
				mem[base_address + expr.patchptr] = value
			when 'C'
				mem[base_address + expr.patchptr .. base_address + expr.patchptr + 1] = [value].pack('v')
			when 'L'
				mem[base_address + expr.patchptr .. base_address + expr.patchptr + 3] = [value].pack('V')
			else
				raise "unknown expr type #{expr.type}"
		end
	end
end

File.open(ARGV[1], 'w') do |io|
	io.write mem[first_addr...last_addr]
end
