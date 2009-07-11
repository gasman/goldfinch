XLIB fatfs_buf_flushone

include "fatfs.def"

LIB fatfs_buf_gethandle
LIB fatfs_buf_writebuf
XREF fatfs_buf_writeany

; ***************************************************************************
; * Flush a single updated buffer                                           *
; ***************************************************************************
; On entry, A=buffer ID
; On exit, IY=buffer handle
;      Fc=1 (success)
;      or, Fc=0 (failure) and A=error
; ADEHL corrupted.

.fatfs_buf_flushone
	push	af
	call	fatfs_buf_gethandle
	pop	af
	scf
	bit	bufflag_upd,(iy+fbh_flags)
	ret	z
	bit	bufflag_inuse,(iy+fbh_flags)
	ret	z
	push	bc
	call	fatfs_buf_writeany + (fatfs_buf_writebuf-fatfs_buf_writebuf)		; write the buffer
	; ^^^ stupid hack to persuade z80asm to explicitly link the buf_writebuf library
	pop	bc
	ret
