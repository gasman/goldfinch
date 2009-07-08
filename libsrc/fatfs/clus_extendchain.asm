XLIB clus_extendchain

include "fatfs.def"

LIB clus_allocate
LIB fat_writefat

; ***************************************************************************
; * Add cluster to chain                                                    *
; ***************************************************************************
; On entry, IX=partition handle, BC=last cluster in current chain
; On exit, Fc=1 (success), with BC=new cluster number (added to chain)
; Or, Fc=1 (fail) and A=error
; ADEHL corrupted

.clus_extendchain
	push	bc
	call	clus_allocate		; allocate a new cluster
	ld	d,b
	ld	e,c			; DE=new cluster
	pop	bc			; BC=current cluster
	ret	nc			; exit if allocation error
	push	de			; save new cluster
	call	fat_writefat		; store at end of chain
	pop	bc			; BC=cluster
	ret				; exit with any error from writing FAT
