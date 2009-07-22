XLIB buffer_setmru
XDEF buffer_getaddress

include "buffer.def"

; ***************************************************************************
; * Subroutine to set the MRU buffer and obtain its address                 *
; ***************************************************************************
; On entry, A=buffer number (0..n-1)
; On exit, HL=address of buffer
; Enter at buf_getaddress to avoid making buffer MRU
; ABCDE corrupted.

.buffer_setmru
	ld	hl,buf_mrulist
	ld	b,a
	ld	c,a
.buf_sm_reorder
	ld	a,(hl)
	ld	(hl),b			; move entries down list
	inc	hl
	ld	b,a
	cp	c
	jr	nz,buf_sm_reorder	; until position of ours is filled
.buffer_getaddress
	inc	a
	ld	hl,buf_buffers-buf_secsize
	ld	de,buf_secsize
.buf_sm_formaddr
	add	hl,de			; form address of buffer
	dec	a
	jr	nz,buf_sm_formaddr
	ret
