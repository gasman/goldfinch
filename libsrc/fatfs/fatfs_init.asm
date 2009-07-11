XLIB fatfs_init

include "fatfs.def"
LIB buf_findbuf_noread

.fatfs_init
	; clear fatfs_data_area
	ld hl,fatfs_data_area
	ld de,fatfs_data_area + 1
	ld bc,fatfs_data_area_end - fatfs_data_area - 1
	ld (hl),0
	ldir
	
	ld	ix,0
	call	buf_findbuf_noread	; get a buffer not associated with a partition - TBD!
	ld	(drive_sectorbuf),hl	; save buffer address for later
	ret
