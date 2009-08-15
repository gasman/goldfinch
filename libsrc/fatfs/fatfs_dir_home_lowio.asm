XLIB fatfs_dir_home_lowio

include "../lowio/lowio.def"
	
; ***************************************************************************
; * "Home" directory handle to first entry                                  *
; ***************************************************************************
; On entry, IY=directory handle (from lowio.def)
; On exit, Fc=1 (success)
; A corrupted.

.fatfs_dir_home_lowio
	ld	a,(iy+dir_fatfs_clusstart)	; copy start cluster (0 for root)
	ld	(iy+dir_fatfs_cluster),a
	ld	a,(iy+dir_fatfs_clusstart+1)
	ld	(iy+dir_fatfs_cluster+1),a
	xor	a
	ld	(iy+dir_fatfs_sector),a	; zero sector offset
	ld	(iy+dir_fatfs_entry),a	; and entry within sector
	scf				; success!
	ret
