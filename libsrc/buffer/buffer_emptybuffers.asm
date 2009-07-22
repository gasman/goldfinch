XLIB buffer_emptybuffers

include "buffer.def"

; ***************************************************************************
; * Subroutine to empty/initialise the buffer details                       *
; ***************************************************************************
; BCDEHL corrupted.

.buffer_emptybuffers
	ld	hl,buf_mrulist
	ld	bc,buf_numbufs*$100	; B=buffers, C=0
	push	bc
.buf_eb_setmru
	ld	(hl),c			; set MRU list to 0,1,...n-1
	inc	hl
	inc	c
	djnz	buf_eb_setmru
	pop	bc
	ld	hl,buf_handles		; TBD: not strictly necessary
	ld	d,c
	ld	e,fbh_size
.buf_eb_setflags
	ld	(hl),d			; set flags to zero (unused)
	add	hl,de
	djnz	buf_eb_setflags
	ret
