class ObjectFile < Struct.new(
	:name, :org_address, :expression_declarations, :name_declarations, :library_name_declarations, :code)

	class ExpressionDeclaration < Struct.new(:type, :patchptr, :expression)
	end

	class NameDeclaration < Struct.new(:scope, :type, :value, :name)
	end

	def self.read(io)
		if io.read(8) != 'Z80RMF01'
			raise "not a Z80asm object file"
		end
		org_address, module_name_ptr, expression_declarations_ptr,
			name_declarations_ptr, library_name_declarations_ptr,
			machine_code_block_ptr = io.read(22).unpack('vVVVVV')
		
		expression_declarations = []
		if expression_declarations_ptr != 0xffffffff
			expression_declarations_length = [name_declarations_ptr, library_name_declarations_ptr, module_name_ptr].min - expression_declarations_ptr
			expression_declarations_bin =
				io.read(expression_declarations_length)
			until expression_declarations_bin == ''
				type, patchptr, length =
					expression_declarations_bin.slice!(0...4).unpack('a1vc')
				expression = expression_declarations_bin.slice!(0...length)
				expression_declarations_bin.slice!(0) # strip off null
				expression_declarations << ExpressionDeclaration.new(type, patchptr, expression)
			end
		end

		name_declarations = []
		if name_declarations_ptr != 0xffffffff
			name_declarations_length = [library_name_declarations_ptr, module_name_ptr].min - name_declarations_ptr
			name_declarations_bin =
				io.read(name_declarations_length)
			until name_declarations_bin == ''
				scope, type, value, length =
					name_declarations_bin.slice!(0...7).unpack('a1a1Vc')
				name = name_declarations_bin.slice!(0...length)
				name_declarations << NameDeclaration.new(scope, type, value, name)
			end
		end
		
		library_name_declarations = []
		if library_name_declarations_ptr != 0xffffffff
			library_name_declarations_bin =
				io.read(module_name_ptr - library_name_declarations_ptr)
			until library_name_declarations_bin == ''
				length = library_name_declarations_bin.slice!(0)
				library_name_declarations << library_name_declarations_bin.slice!(0...length)
			end
		end
		
		module_name_length, = io.read(1).unpack('c')
		module_name = io.read(module_name_length)
		
		code_length, = io.read(2).unpack('v')
		code = io.read(code_length)
		
		new(module_name, org_address, expression_declarations, name_declarations,
			library_name_declarations, code)
	end
	
	def describe
		out = ''
		out << "#{name}, org #{org_address}\n===============\n"
		out << "Expression declarations:\n"
		for expr in expression_declarations
			out << "#{expr.type == 'C' ? 'Constant' : 'Relocatable address'} at #{expr.patchptr} = #{expr.expression}\n"
		end

		out << "\nName declarations:\n"
		for name in name_declarations
			out << "#{name.scope} #{name.type} #{name.name} = #{name.value}\n"
		end

		out << "\nLibrary name declarations:\n"
		for name in library_name_declarations
			out << "#{name}\n"
		end
		out
	end
end
