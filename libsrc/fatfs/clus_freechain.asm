XLIB clus_freechain

include "fatfs.def"

LIB clus_valid
LIB fat_readfat
LIB fat_writefat

; ***************************************************************************
; * Free entire cluster chain                                               *
; ***************************************************************************
; On entry, IX=partition handle, BC=starting cluster
; On exit, Fc=1 (success)
; Or, Fc=1 (fail) and A=error
; ABCDEHL corrupted

.clus_freechain
	call	clus_valid
	ccf
	ret	c			; end of chain reached
	push	bc
	call	fat_readfat		; get next cluster in chain
	jr	nc,clus_freechain_error
	ld	d,b
	ld	e,c
	pop	bc			; BC=cluster to free
	push	de			; save next cluster in chain
	inc	(ix+fph_freeclusts)	; increment free clusters
	jr	nz,clus_fc_nocarry
	inc	(ix+fph_freeclusts+1)
.clus_fc_nocarry
	ld	de,$0000
	call	fat_writefat		; write 0 to FAT entry, to free up
.clus_freechain_error
	pop	bc			; BC=next cluster
	jr	c,clus_freechain	; go to free remainder of chain
	ret				; exit with error
