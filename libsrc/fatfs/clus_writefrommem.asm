XLIB clus_writefrommem

include "fatfs.def"

LIB clus_getsector
LIB buf_findbuf_noread
LIB buf_writebuf

; ***************************************************************************
; * Write sector to cluster                                                 *
; ***************************************************************************
; On entry, IX=partition handle, BC=cluster number, A=sector offset
; and HL=sector address
; On exit, Fc=1 (success)
; Or, Fc=0, failure (A=error)
; ABCDEHL corrupted.

.clus_writefrommem
	push	hl			; save source
	call	clus_getsector		; BCDE=logical sector
	pop	hl
	ret	nc			; exit if error
	push	hl			; save source
	call	buf_findbuf_noread	; find buffer, but don't read from disk
	ex	de,hl
	pop	hl
	ld	bc,buf_secsize
	ldir				; move to buffer
	jp	buf_writebuf		; write the MRU buffer (this one)
