XLIB buffer_findbuf

include "buffer.def"

LIB buffer_findbuf_noread
XREF buffer_locatebuf
LIB read_block_asm

; ***************************************************************************
; * Subroutine to get buffer for sector, reading from disk if necessary     *
; ***************************************************************************
; On entry, BCDE=sector required, IX=partition handle (or actually any struct that behaves as a block_device)
; On exit, Fc=1 (success) and HL=address of buffer
; or Fc=0 and A=error.
; This will update the MRU list
; ABCDEHL corrupted. IY preserved

.buffer_findbuf
	push	iy
	call buffer_locatebuf + buffer_findbuf_noread - buffer_findbuf_noread
	; ^^^ nasty hack to force import of the buffer_findnoread library
	jr	c,buf_findbuf_ok	; exit if contents already valid
	push	hl			; save buffer address
	ld	e,(iy+fbh_sector)
	ld	d,(iy+fbh_sector+1)
	ld	c,(iy+fbh_sector+2)
	ld	b,(iy+fbh_sector+3)	; BCDE=sector
	call	read_block_asm
	pop	hl			; retrieve buffer address
	jr	c,buf_findbuf_ok	; exit if no error
	res	bufflag_inuse,(iy+fbh_flags)	; not valid if error
.buf_findbuf_ok
	pop	iy
	ret
