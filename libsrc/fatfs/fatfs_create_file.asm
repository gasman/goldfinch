XLIB fatfs_create_file

LIB fatfs_file_create_entry
LIB fatfs_open_dirent
LIB fatfs_file_sanitise_filename

include	"../lowio/lowio.def"

; enter with IY = dir handle, HL = null-terminated filename, C = access mode
; return with HL = file handle
.fatfs_create_file
	push bc	; save acces mode

	push hl
	
	call fatfs_file_sanitise_filename	; ensure that passed filename is valid

	; get partition handle into ix
	ld l,(iy + dir_filesystem + filesystem_fatfs_phandle)
	ld h,(iy + dir_filesystem + filesystem_fatfs_phandle + 1)
	push hl
	pop ix

	pop hl
	call fatfs_file_create_entry
	; fatfs_open_dirent only looks at the dir portion of the dirent it receives,
	; so we can cheat and just pass the dir instead
	push iy
	pop hl	; get dir handle into hl
	pop bc	; restore access mode
	jp fatfs_open_dirent
