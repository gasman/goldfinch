XLIB fatfs_clus_getsector

include "fatfs.def"

; ***************************************************************************
; * Subroutine to calculate sector number of cluster portion                *
; ***************************************************************************
; On entry, IX=partition handle, BC=cluster number and A=sector offset
; On exit, Fc=1 (success) and BCDE=sector number
; Or, Fc=0 and A=error
; AHL corrupted.

.fatfs_clus_getsector
	cp	(ix+fph_clussize)	; ensure sector offset in range
	jr	nc,clus_getsector_seekerr
	ld	h,0
	ld	l,a
	ld	a,h			; AHL=sector offset
	dec	bc
	dec	bc			; BC=cluster-2
	ld	e,(ix+fph_clussize)
.clus_getsector_loop
	add	hl,bc
	adc	a,0			; form AHL=sector offset+clussize*(cluster-2)
	dec	e
	jr	nz,clus_getsector_loop
	ld	c,(ix+fph_data_start)
	ld	b,(ix+fph_data_start+1)
	add	hl,bc
	adc	a,(ix+fph_data_start+2)	; AHL=logical sector number in partition
	ex	de,hl
	ld	c,a
	ld	b,0			; BCDE=logical sector number
	scf				; success!
	ret
.clus_getsector_seekerr
	ld	a,rc_seek		; Fc=0 already; seek error
	ret
