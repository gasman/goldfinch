XLIB fatfs_dir_change

include "fatfs.def"

LIB fatfs_dir_entrydetails
LIB fatfs_dir_root_callee
XREF fatfs_dir_root_asmentry
LIB fatfs_dir_home

; ***************************************************************************
; * Change directory to current entry                                       *
; ***************************************************************************
; On entry, IY=directory handle, IX=partition handle
; On exit, Fc=1 (success)
; or, Fc=0 (failure) and A=error
; ABCDEHL corrupted.

.fatfs_dir_change
	call	fatfs_dir_entrydetails	; get details
	ret	nc			; exit if error
	jr	z,dir_change_badentry	; no good if free entry
	bit	dirattr_dir,a
	jr	z,dir_change_badentry	; no good if not directory
	ld	bc,direntry_cluster
	add	hl,bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)			; BC=directory start cluster
	ld	a,b
	or	c
	jp	z,fatfs_dir_root_asmentry + (fatfs_dir_root_callee-fatfs_dir_root_callee)	; set root directory if necessary
	ld	(iy+fdh_clusstart),c
	ld	(iy+fdh_clusstart+1),b	; set start cluster
	res	7,(iy+fdh_flags)	; signal subdirectory
	jp	fatfs_dir_home		; home to first entry
.dir_change_badentry
	ld	a,rc_notdir
	and	a			; Fc=0
	ret
