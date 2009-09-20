; Data area for MBR / partitioning support
XLIB mbr_data
XDEF mbr_next_partition_entry
XDEF mbr_partition_entries

include "mbr.def"

.mbr_data

.mbr_next_partition_entry	defw 0	; pointer to next partition entry to define
; area in which to allocate partition block devices
.mbr_partition_entries
	; each entry is the block device handle followed by a partition_data struct
	defs MBR_PARTITION_COUNT * (blockdev_size + partition_data_size)
