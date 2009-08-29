; FILE *fatfs_open_dirent(DIRENT *dirent, unsigned char access_mode)
XLIB fatfs_open_dirent

LIB fatfs_file_allocate
LIB fatfs_dir_getentry
; LIB fatfs_file_validate_access
LIB fatfs_file_set_access
XREF fatfs_file_validate_access
; FIXME: figure out why importing fatfs_file_validate_access as a lib isn't working

include "fatfs.def"
include	"../lowio/lowio.def"

; enter with hl = dirent, c = access mode
.fatfs_open_dirent
	push bc	; save access mode
	push hl ; save dirent
	
	call fatfs_file_allocate ; get file pointer into hl
	ex de,hl
	pop hl ; restore dirent
	push de ; save file/dir/filesytem pointer
	
	; copy dir struct from dirent to file
	ld bc,dir_size
	ldir

	; zeroize everything from here up to clusstart
	ld h,d
	ld l,e
	ld (hl),0	; hl points to start of file_fsdata
	inc de
	ld bc,file_fatfs_clusstart - file_fsdata - 1
	ldir
	
	pop iy	; file/dir/filesystem pointer in iy
	; get partition handle into ix
	ld l,(iy + dir_filesystem + filesystem_fatfs_phandle)
	ld h,(iy + dir_filesystem + filesystem_fatfs_phandle + 1)
	push hl
	pop ix

	push de ; preserve pointer to clusstart record
	call fatfs_dir_getentry ; get address of on-disk dir entry into hl
	pop de

	ld bc,direntry_cluster
	add hl,bc	; point hl at the clusstart entry
	ld bc,2+4
	ldir	; copy clusstart and filesize records
	
	; now perform file_validate_access etc
	pop bc
	ld b,0	; B="original" access mode
	call fatfs_file_validate_access + fatfs_file_set_access - fatfs_file_set_access
	push iy
	pop hl ; return with file handle in hl
	scf
	ret