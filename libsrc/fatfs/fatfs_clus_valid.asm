XLIB fatfs_clus_valid

include "fatfs.def"

; ***************************************************************************
; * Check cluster validity                                                  *
; ***************************************************************************
; On entry, IX=partition handle, BC=cluster number
; On exit, Fc=1 (success) if cluster is valid
; Or, Fc=0 (fail) if not
; A corrupted.

.fatfs_clus_valid
	push	hl
	ld	hl,$0001
	and	a
	sbc	hl,bc
	pop	hl
	ret	nc			; invalid if $0000 or $0001
	push	hl
	ld	l,(ix+fph_maxclust)
	ld	h,(ix+fph_maxclust+1)
	and	a
	sbc	hl,bc			; Fc=1 if BC > max cluster
	ccf				; Fc=1 if BC <= max cluster
	pop	hl
	ret
