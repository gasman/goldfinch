; void fatfs_open_subdir(DIRENT *dirent, DIR *dir) - open the dirent as a directory

XLIB fatfs_open_subdir

LIB fatfs_dir_entrydetails
LIB fatfs_open_root_dir
LIB fatfs_dir_home

include "../lowio/lowio.def"
include "fatfs.def"

; enter with IY = dirent, DE = destination dir
.fatfs_open_subdir
	; get partition handle into ix
	ld l,(iy + filesystem_fatfs_phandle)
	ld h,(iy + filesystem_fatfs_phandle + 1)
	push hl
	pop ix
	push de
	call	fatfs_dir_entrydetails	; get details
	pop de
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

	push iy ; get filesystem / dir handle in hl, from start of dirent
	pop hl

	jp z,fatfs_open_root_dir	; if start cluster is 0, open root dir
	
	; otherwise, copy dir handle
	push bc
	ld bc,dir_fatfs_size
	push de
	ldir
	pop iy	; iy now points to new dir handle
	pop bc
	ld	(iy+dir_fatfs_clusstart),c
	ld	(iy+dir_fatfs_clusstart+1),b	; set start cluster
	res	7,(iy+dir_fatfs_flags)	; signal subdirectory
	jp	fatfs_dir_home		; home to first entry
	
.dir_change_badentry
	ld	a,rc_notdir
	and	a			; Fc=0
	ret
