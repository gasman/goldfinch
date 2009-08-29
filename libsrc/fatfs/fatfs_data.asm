; Global data area for fatfs library

XLIB fatfs_data

XDEF file_handles
XDEF part_handles
XDEF drive_sectorbuf
XDEF tmp_rwaddr
XDEF tmp_rwsize
XDEF tmp_rwpossible
XDEF fatfs_data_end

include	"../lowio/lowio.def"
include	"fatfs.def"

.fatfs_data
; Structures
.file_handles	defs	file_fatfs_size*file_numhandles ; file handles
.part_handles	defs	fph_size*part_numhandles ; partition handles

; Miscellaneous variables
.drive_sectorbuf	defw	0	; pointer to sector buffer used for MBRs etc

.tmp_rwaddr	defw	0	; temporary variables used by read/write
.tmp_rwsize	defw	0
.tmp_rwpossible	defw	0
.fatfs_data_end
