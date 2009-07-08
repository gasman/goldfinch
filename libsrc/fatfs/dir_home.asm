XLIB dir_home

include "fatfs.def"
	
; ***************************************************************************
; * "Home" directory handle to first entry                                  *
; ***************************************************************************
; On entry, IY=directory handle
; On exit, Fc=1 (success)
; A corrupted.

.dir_home
	ld	a,(iy+fdh_clusstart)	; copy start cluster (0 for root)
	ld	(iy+fdh_cluster),a
	ld	a,(iy+fdh_clusstart+1)
	ld	(iy+fdh_cluster+1),a
	xor	a
	ld	(iy+fdh_sector),a	; zero sector offset
	ld	(iy+fdh_entry),a	; and entry within sector
	scf				; success!
	ret
