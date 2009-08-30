require 'object_file'

module LibraryFile
	def self.read(io)
		if io.read(8) != 'Z80LMF01'
			raise "not a Z80asm library file"
		end
		
		next_object_file_ptr = 8
		
		objects = []
		
		while next_object_file_ptr != 0xffffffff
			io.seek(next_object_file_ptr)
			next_object_file_ptr, object_file_length = io.read(8).unpack('VV')
			objects << ObjectFile.read(io)
		end
		
		objects
	end
end
