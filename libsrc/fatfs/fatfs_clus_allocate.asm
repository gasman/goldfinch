XLIB fatfs_clus_allocate

include "fatfs.def"

LIB fatfs_clus_valid
LIB fatfs_fat_readfat
LIB fatfs_fat_writefat

; ***************************************************************************
; * Allocate new cluster                                                    *
; ***************************************************************************
; On entry, IX=partition handle
; On exit, Fc=1 (success), with BC=cluster number
; Or, Fc=1 (fail) and A=error
; ADEHL corrupted

.fatfs_clus_allocate
	ld	c,(ix+fph_lastalloc)
	ld	b,(ix+fph_lastalloc+1)	; BC=last cluster allocated
	push	bc
.clus_allocate_search
	inc	bc			; try next cluster
	pop	hl			; HL=starting cluster number
	push	hl
	and	a
	sbc	hl,bc
	jr	z,clus_allocate_failed	; failed if searched entire FAT
	call	fatfs_clus_valid
	jr	c,clus_allocate_try
	ld	bc,$0001		; loop to first valid cluster
	jr	clus_allocate_search
.clus_allocate_try
	push	bc			; save cluster number
	call	fatfs_fat_readfat		; read its entry
	jr	c,clus_allocate_readok
	pop	hl			; discard stack items
	pop	hl
	ret				; exit with error
.clus_allocate_readok
	ld	a,b
	or	c			; is it free? (0)
	pop	bc			; restore cluster number
	jr	nz,clus_allocate_search	; keep going if in use
	pop	hl			; discard search start point
	ld	(ix+fph_lastalloc),c	; update last allocation
	ld	(ix+fph_lastalloc+1),b
	push	bc
	ld	e,(ix+fph_freeclusts)
	ld	d,(ix+fph_freeclusts+1)
	dec	de			; reduce free clusters
	ld	(ix+fph_freeclusts),e
	ld	(ix+fph_freeclusts+1),d
	ld	de,$ffff
	call	fatfs_fat_writefat		; mark as allocated (last in chain)
	pop	bc			; restore cluster number
	ret				; exit with any error from writing FAT
.clus_allocate_failed
	pop	hl			; discard starting point
	ld	a,rc_diskfull
	and	a			; Fc=0
	ret
