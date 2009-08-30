class MemoryMap
	def initialize(*ranges)
		ranges = [(0x0000..0xffff)] if ranges.empty?
		@ranges = ranges
	end
	
	# FIXME: why oh why is this so slow?
	def allocate(start_address_range, block_size)
		@ranges.each_with_index do |range, i|
			# try to allocate from start of range
			if start_address_range === range.min and range.min + block_size <= range.max + 1
				@ranges.delete_at(i)
				@ranges.insert(i, range.min + block_size .. range.max) unless range.min + block_size > range.max
				return range.min
			# otherwise, try to allocate from base of start_address_range
			elsif range === start_address_range.min and start_address_range.min + block_size <= range.max + 1
				@ranges.delete_at(i)
				@ranges.insert(i, range.min ... start_address_range.min)
				@ranges.insert(i+1, start_address_range.min + block_size .. range.max) unless start_address_range.min + block_size > range.max
				return start_address_range.min
			end
		end
		nil
	end
end
