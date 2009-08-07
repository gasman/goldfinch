XLIB buffer_update

include "buffer.def"

LIB buffer_gethandle
LIB buf_mrulist

; ***************************************************************************
; * Flag the MRU buffer as updated                                          *
; ***************************************************************************
; ADE corrupted.

.buffer_update
	push	iy
	ld	a,(buf_mrulist)
	call	buffer_gethandle		; get MRU buffer handle
	set	bufflag_upd,(iy+fbh_flags)	; set update flag
	pop	iy
	ret
