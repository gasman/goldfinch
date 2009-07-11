XLIB fatfs_buf_update

include "fatfs.def"

LIB fatfs_buf_gethandle

; ***************************************************************************
; * Flag the MRU buffer as updated                                          *
; ***************************************************************************
; ADE corrupted.

.fatfs_buf_update
	push	iy
	ld	a,(buf_mrulist)
	call	fatfs_buf_gethandle		; get MRU buffer handle
	set	bufflag_upd,(iy+fbh_flags)	; set update flag
	pop	iy
	ret
