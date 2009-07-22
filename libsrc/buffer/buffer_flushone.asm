XLIB buffer_flushone

include "buffer.def"

LIB buffer_gethandle
LIB buffer_writebuf
XREF buffer_writeany

; ***************************************************************************
; * Flush a single updated buffer                                           *
; ***************************************************************************
; On entry, A=buffer ID
; On exit, IY=buffer handle
;      Fc=1 (success)
;      or, Fc=0 (failure) and A=error
; ADEHL corrupted.

.buffer_flushone
	push	af
	call	buffer_gethandle
	pop	af
	scf
	bit	bufflag_upd,(iy+fbh_flags)
	ret	z
	bit	bufflag_inuse,(iy+fbh_flags)
	ret	z
	push	bc
	call	buffer_writeany + (buffer_writebuf-buffer_writebuf)		; write the buffer
	; ^^^ stupid hack to persuade z80asm to explicitly link the buf_writebuf library
	pop	bc
	ret
