XLIB fatfs_dir_root_callee
XDEF fatfs_dir_root_asmentry

include "fatfs.def"

LIB fatfs_dir_home

; extern void __LIB__ __CALLEE__ fatfs_dir_root_callee(FATFS_FILESYSTEM *fs, FATFS_DIRECTORY *dir);
.fatfs_dir_root_callee
	pop hl	; return address
	pop iy	; dir
	pop ix	; fs
	push hl

; ***************************************************************************
; * Initialise directory handle to root of current partition                *
; ***************************************************************************
; On entry, IY=directory handle, IX=partition handle
; On exit, Fc=1 (success)
; A corrupted.

.fatfs_dir_root_asmentry
	ld	a,ixl			; set partition handle
	ld	(iy+fdh_phandle),a
	ld	a,ixh
	ld	(iy+fdh_phandle+1),a
	set	7,(iy+fdh_flags)	; signal root directory
	xor	a
	ld	(iy+fdh_clusstart),a	; set start sector offset to zero
	ld	(iy+fdh_clusstart+1),a
	; Fall into dir_home to set current entry to first
	jp fatfs_dir_home