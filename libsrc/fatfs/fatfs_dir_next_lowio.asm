XLIB fatfs_dir_next_lowio

include	"../lowio/lowio.def"
include "fatfs.def"

LIB fatfs_clus_nextsector

; ***************************************************************************
; * Move to next directory entry                                            *
; ***************************************************************************
; On entry, IY=directory handle (lowio.def), IX=partition handle
; On exit, Fc=1 (success)
; or, Fc=0 (failure) and A=error
; ABCDEHL corrupted.

.fatfs_dir_next_lowio
	inc	(iy+dir_fatfs_entry)		; increment entry number
	bit	4,(iy+dir_fatfs_entry)	; Fz=1 if entry < 16
	scf				; success!
	ret	z			; exit if still in same sector
	bit	7,(iy+dir_fatfs_flags)	; root directory?
	jr	nz,dir_next_root
	ld	c,(iy+dir_fatfs_cluster)
	ld	b,(iy+dir_fatfs_cluster+1)
	ld	a,(iy+dir_fatfs_sector)
	call	fatfs_clus_nextsector		; increment to next sector
	ret	nc			; exit if error
	ld	(iy+dir_fatfs_cluster),c	; store new location in handle
	ld	(iy+dir_fatfs_cluster+1),b
	ld	(iy+dir_fatfs_sector),a
	ld	(iy+dir_fatfs_entry),0	; first entry in sector
	ret				; exit with Fc=1, success
.dir_next_root
	ld	c,(iy+dir_fatfs_cluster)
	ld	b,(iy+dir_fatfs_cluster+1)	; BC=sector offset
	inc	bc			; move to next
	ld	l,(ix+fph_rootsize)
	ld	h,(ix+fph_rootsize+1)	; HL=number of sectors in root
	dec	hl			; HL=max sector offset
	and	a
	sbc	hl,bc			; Fc=1 if sector too large
	ld	a,rc_dirfull
	ccf
	ret	nc			; exit if error
	ld	(iy+dir_fatfs_cluster),c	; update sector offset
	ld	(iy+dir_fatfs_cluster+1),b
	ld	(iy+dir_fatfs_entry),0	; first entry in sector
	ret				; exit with Fc=1, success
