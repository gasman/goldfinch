; void fatfs_open_dirent(DIRENT *dirent, FILE *file)
XLIB fatfs_open_dirent

include	"../lowio/lowio.def"

; enter with ix = dirent, de = file
.fatfs_open_dirent
	push ix	; save dirent
	ld l,(ix + dirent_dir_ptr)
	ld h,(ix + dirent_dir_ptr + 1)
	; copy filesystem struct to file
	ld bc,filesystem_size
	ldir

	; zeroize everything from here up to clusstart
	ld h,d
	ld l,e
	ld (hl),0	; hl points to start of file_fsdata
	inc de
	ld bc,file_fatfs_clusstart - file_fsdata - 1
	ldir
	
	pop hl	; restore dirent
	ld bc,dirent_fatfs_clusstart
	add hl,bc	; point hl at the clusstart entry
	ld bc,dirent_fatfs_copyend - dirent_fatfs_clusstart
	ldir	; copy clusstart and filesize records
	ret
	