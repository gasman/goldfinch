XLIB fatfs_buf_findbuf

include "fatfs.def"

LIB fatfs_buf_findbuf_noread
XREF fatfs_buf_locatebuf

LIB read_block_callee
XREF read_block_asmentry

; ***************************************************************************
; * Subroutine to get buffer for sector, reading from disk if necessary     *
; ***************************************************************************
; On entry, BCDE=sector required, IX=partition handle (or actually any struct that behaves as a block_device)
; On exit, Fc=1 (success) and HL=address of buffer
; or Fc=0 and A=error.
; This will update the MRU list
; ABCDEHL corrupted.

.fatfs_buf_findbuf
	push	iy
	call fatfs_buf_locatebuf + fatfs_buf_findbuf_noread - fatfs_buf_findbuf_noread
	; ^^^ nasty hack to force import of the fatfs_buf_findnoread library
	jr	c,buf_findbuf_ok	; exit if contents already valid
	push	hl			; save buffer address
	ld	e,(iy+fbh_sector)
	ld	d,(iy+fbh_sector+1)
	ld	c,(iy+fbh_sector+2)
	ld	b,(iy+fbh_sector+3)	; BCDE=sector
	call	read_block_asmentry + (read_block_callee-read_block_callee)
	pop	hl			; retrieve buffer address
	jr	c,buf_findbuf_ok	; exit if no error
	res	bufflag_inuse,(iy+fbh_flags)	; not valid if error
.buf_findbuf_ok
	pop	iy
	ret
