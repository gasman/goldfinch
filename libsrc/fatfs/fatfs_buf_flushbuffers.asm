XLIB fatfs_buf_flushbuffers

include "fatfs.def"

LIB fatfs_buf_flushone

; ***************************************************************************
; * Flush any updated buffers                                               *
; ***************************************************************************
; On exit, Fc=1 (success)
;      or, Fc=0 (failure) and A=error
; ABCDEHL corrupted.

.fatfs_buf_flushbuffers
	push	ix
	push	iy
	ld	b,buf_numbufs
.buf_flush_loop
	ld	a,buf_numbufs
	sub	b			; A=buffer number
	call	fatfs_buf_flushone
	jr	nc,buf_flush_error	; exit if error
	djnz	buf_flush_loop		; else do others
.buf_flush_error
	pop	iy
	pop	ix
	ret
