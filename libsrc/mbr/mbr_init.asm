; initialise MBR/partition handler
XLIB mbr_init

LIB mbr_next_partition_entry
LIB mbr_partition_entries

.mbr_init
	; set mbr_next_partition_entry to the first one
	ld hl,mbr_partition_entries
	ld (mbr_next_partition_entry),hl
	ret
	