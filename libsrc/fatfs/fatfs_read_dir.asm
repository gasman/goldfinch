; int fatfs_read_dir(DIR *dir, DIRENT *dirent) - read the next entry from a directory
XLIB fatfs_read_dir

LIB fatfs_dir_getentry_lowio
LIB fatfs_dir_next_lowio

include	"../lowio/lowio.def"

; enter with hl = dir, ix = dirent
; returns 0 if end of dir
.fatfs_read_dir
	; first make a pointer to the dir (which is handily also a pointer to (a copy of) the filesystem).
	; NB this requires the calling code NOT to deallocate the dir before it's finished doing stuff
	; with this dirent (such as opening the file in question)...
	ld (ix + dirent_dir_ptr),l
	ld (ix + dirent_dir_ptr + 1),h
	
	; store dirent for later
	push ix
	
	; get dir handle into iy
	push hl
	pop iy

	; get pointer to the partition handle into ix
	ld l,(iy + filesystem_fatfs_phandle)
	ld h,(iy + filesystem_fatfs_phandle + 1)
	push hl
	pop ix
	
	; get address of dir entry into hl
	call fatfs_dir_getentry_lowio
	; restore dirent
	pop de
	
	; check for end of dir / other error condition
	jr nc,end_of_dir
	
	; copy filename to dir entry
	inc de
	inc de	; advance to the dirent_filename field
	ld bc,8
	ldir
	; rewind to the character following the last non-space character
.remove_trailing_space
	dec de
	ld a,(de)
	cp ' '
	jr z,remove_trailing_space
	inc de
	; if extension is blank, null-terminate now
	ld a,(hl)
	cp ' '
	jr z,null_terminate
	; otherwise place a dot here
	ld a,'.'
	ld (de),a
	; add the extension
	inc de
	ldi
	ldi
	ldi

	; rewind to the last non-space character
.remove_trailing_space_after_ext
	dec de
	ld a,(de)
	cp ' '
	jr z,remove_trailing_space_after_ext
	; then null-terminate
	inc de
.null_terminate
	xor a
	ld (de),a
	
	; advance dir to next entry
	call fatfs_dir_next_lowio

	scf	; signal success
	ld hl,1
	ret
.end_of_dir
	ld hl,0
	ret
