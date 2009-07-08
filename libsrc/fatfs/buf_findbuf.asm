XLIB buf_findbuf

include "fatfs.def"

LIB buf_findbuf_noread
XREF buf_locatebuf

LIB read_block_callee
XREF ASMDISP_READ_BLOCK_CALLEE

; ***************************************************************************
; * Subroutine to get buffer for sector, reading from disk if necessary     *
; ***************************************************************************
; On entry, BCDE=sector required, IX=block device handle
; On exit, Fc=1 (success) and HL=address of buffer
; or Fc=0 and A=error.
; This will update the MRU list
; ABCDEHL corrupted.

.buf_findbuf
	push	iy
	call	buf_locatebuf
	jr	c,buf_findbuf_ok	; exit if contents already valid
	push	hl			; save buffer address
	ld	e,(iy+fbh_sector)
	ld	d,(iy+fbh_sector+1)
	ld	c,(iy+fbh_sector+2)
	ld	b,(iy+fbh_sector+3)	; BCDE=sector
	call	read_block_callee + ASMDISP_READ_BLOCK_CALLEE	; read sector
	pop	hl			; retrieve buffer address
	jr	c,buf_findbuf_ok	; exit if no error
	res	bufflag_inuse,(iy+fbh_flags)	; not valid if error
.buf_findbuf_ok
	pop	iy
	ret
