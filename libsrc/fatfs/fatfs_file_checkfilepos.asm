XLIB fatfs_file_checkfilepos

include	"../lowio/lowio.def"

; ***************************************************************************
; * Subroutine to check fileposition                                        *
; ***************************************************************************
; Entry: IY=filehandle
; Exit: Fc=1 if fileposition within current file size, Fc=0 if not
; DEHL corrupt.

.fatfs_file_checkfilepos
	ld	l,(iy+file_fatfs_filepos)
	ld	h,(iy+file_fatfs_filepos+1)
	ld	e,(iy+file_fatfs_filesize)
	ld	d,(iy+file_fatfs_filesize+1)
	and	a
	sbc	hl,de
	ld	l,(iy+file_fatfs_filepos+2)
	ld	h,(iy+file_fatfs_filepos+3)
	ld	e,(iy+file_fatfs_filesize+2)
	ld	d,(iy+file_fatfs_filesize+3)
	sbc	hl,de			; Fc=1 if size > filepos (okay)
	ret
