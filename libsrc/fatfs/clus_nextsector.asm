XLIB clus_nextsector

include "fatfs.def"

LIB fat_readfat
LIB clus_valid

; ***************************************************************************
; * Get next cluster portion                                                *
; ***************************************************************************
; On entry, IX=partition handle, BC=cluster number, A=sector offset
; On exit, Fc=1 (success) with BC & A updated to next cluster portion
; Or, Fc=0 (fail) and A=error if end of cluster chain reached (or FAT read error).
; DEHL corrupted.

.clus_nextsector
	inc	a
	cp	(ix+fph_clussize)
	ret	c			; OK if < number of sectors per cluster
	call	fat_readfat		; get next cluster in chain
	ret	nc			; exit if error reading FAT
	call	clus_valid
	ld	a,rc_eof
	ret	nc			; exit if end of cluster chain
.clus_nextsector_use
	xor	a			; sector offset=0
	scf				; success!
	ret
