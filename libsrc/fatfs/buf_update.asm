XLIB buf_update

include "fatfs.def"

LIB buf_gethandle

; ***************************************************************************
; * Flag the MRU buffer as updated                                          *
; ***************************************************************************
; ADE corrupted.

.buf_update
	push	iy
	ld	a,(buf_mrulist)
	call	buf_gethandle		; get MRU buffer handle
	set	bufflag_upd,(iy+fbh_flags)	; set update flag
	pop	iy
	ret
