XLIB fatfs_file_maximisefilesize

LIB fatfs_file_checkfilepos
LIB fatfs_file_getfilepos

include	"../lowio/lowio.def"
include	"fatfs.def"

; ***************************************************************************
; * Subroutine to ensure filesize includes current fileposition             *
; ***************************************************************************
; Entry: IY=filehandle
; Exit: -
; DEHL corrupt. IX + IY preserved

.fatfs_file_maximisefilesize
	call	fatfs_file_checkfilepos	; is filepos within size?
	ret	c			; exit if so
	call	fatfs_file_getfilepos		; get DEHL=filepos
	inc	l			; increment it, as size must be 1 larger
	jr	nz,file_maximise_nowrap
	inc	h
	jr	nz,file_maximise_nowrap
	inc	e
	jr	nz,file_maximise_nowrap
	inc	d
.file_maximise_nowrap
	ld	(iy+file_fatfs_filesize),l	; store in filesize
	ld	(iy+file_fatfs_filesize+1),h
	ld	(iy+file_fatfs_filesize+2),e
	ld	(iy+file_fatfs_filesize+3),d
	set	fm_entry,(iy+file_fatfs_mode)	; file-entry needs rewriting
	ret
