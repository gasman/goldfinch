; int fatfs_seek_file(FILE *file, unsigned long pos)
XLIB fatfs_seek_file

include	"fatfs.def"
include	"../lowio/lowio.def"

; enter with: IY = file, DEHL = pos
.fatfs_seek_file
	ld	(iy+file_fatfs_filepos),l
	ld	(iy+file_fatfs_filepos+1),h
	ld	(iy+file_fatfs_filepos+2),e
	ld	(iy+file_fatfs_filepos+3),d	; set filepos
	res	fm_valid,(iy+file_fatfs_mode)	; no longer valid location
	scf				; success!
	ret
