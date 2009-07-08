XLIB clus_readtomem

include "fatfs.def"

LIB clus_readtobuf

; ***************************************************************************
; * Read sector from cluster to destination                                 *
; ***************************************************************************
; On entry, IX=partition handle, BC=cluster number, A=sector offset,
; and HL=address
; On exit, Fc=1 (success)
; Or, Fc=0, failure (A=error)
; ABCDEHL corrupted.
	
.clus_readtomem
	push	hl			; save destination
	call	clus_readtobuf		; read to buffer
	pop	de
	ret	nc			; exit if error
	ld	bc,buf_secsize
	ldir				; move to destination
	scf				; success!
	ret
