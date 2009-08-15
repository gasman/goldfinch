; void fatfs_open_root_dir(FILESYSTEM *fs, DIR *dir) - open the root directory of the filesystem
XLIB fatfs_open_root_dir

LIB fatfs_dir_home_lowio

include	"../lowio/lowio.def"

; enter with hl = filesystem, de = dir
.fatfs_open_root_dir
	push de
	; first make a copy of the filesystem object
	ld bc,filesystem_size
	ldir

	pop iy	; restore directory handle
	set	7,(iy+dir_fatfs_flags)	; signal root directory
	xor	a
	ld	(iy+dir_fatfs_clusstart),a	; set start sector offset to zero
	ld	(iy+dir_fatfs_clusstart+1),a
	; Fall into dir_home to set current entry to first
	jp fatfs_dir_home_lowio
