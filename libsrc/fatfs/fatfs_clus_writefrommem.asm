XLIB fatfs_clus_writefrommem

include "fatfs.def"

LIB fatfs_clus_getsector
LIB buffer_findbuf_noread
LIB buffer_writebuf

; ***************************************************************************
; * Write sector to cluster                                                 *
; ***************************************************************************
; On entry, IX=partition handle, BC=cluster number, A=sector offset
; and HL=sector address
; On exit, Fc=1 (success)
; Or, Fc=0, failure (A=error)
; ABCDEHL corrupted.

.fatfs_clus_writefrommem
	push	hl			; save source
	call	fatfs_clus_getsector		; BCDE=logical sector
	pop	hl
	ret	nc			; exit if error
	push	hl			; save source
	call	buffer_findbuf_noread	; find buffer, but don't read from disk
	ex	de,hl
	pop	hl
	ld	bc,buf_secsize
	ldir				; move to buffer
	jp	buffer_writebuf		; write the MRU buffer (this one)
