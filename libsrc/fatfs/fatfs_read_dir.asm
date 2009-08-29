; int fatfs_read_dir(DIR *dir, DIRENT *dirent) - read the next entry from a directory
XLIB fatfs_read_dir

LIB fatfs_dir_entrydetails
LIB fatfs_dir_next

include	"fatfs.def"
include	"../lowio/lowio.def"

; enter with iy = dir, de = dirent
; returns 0 if end of dir
.fatfs_read_dir

.test_entry
	; get partition handle into ix
	ld l,(iy + dir_filesystem + filesystem_fatfs_phandle)
	ld h,(iy + dir_filesystem + filesystem_fatfs_phandle + 1)
	push hl
	pop ix

	; If a previous pass of dir_next returned an 'end of directory' condition,
	; dir_fatfs_entry will have been left with bit 4 set
	bit	4,(iy+dir_fatfs_entry)
	jr nz,end_of_dir
	
	push de ; save dirent
	call fatfs_dir_entrydetails ; get pointer to on-disk dir entry into hl
	pop de ; restore dirent
	
	ret	nc			; exit if error
	jr	z,skip_entry	; no match if free entry
	bit	dirattr_vol,a
	jr	nz,skip_entry	; no match if volume label (which includes LFN entries too)
	
	; we now have a good entry;
	; hl = pointer to on-disk dir entry
	; de = pointer to dirent
	; ix = partition handle
	; iy = pointer to dir

	push de ; store pointer to dirent
	push hl	; store pointer to on-disk dir entry
	
	push iy	; get pointer to dir struct into hl
	pop hl
	ld bc,dir_size ; copy the dir struct to start of dirent
	ldir
	
	pop hl ; restore pointer to on-disk dir entry
	; copy filename to dir entry
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
	jr z,no_extension
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
	jr null_terminate
.no_extension
	inc hl	; skip hl past extension
	inc hl
	inc hl
.null_terminate
	xor a
	ld (de),a
	
	ld e,(hl)	; read attribute byte
	
	pop hl ; restore pointer to dirent
	ld bc,dirent_flags
	add hl,bc
	
	bit	dirattr_dir,e ; test if this is a directory
	jr z,not_directory
	or 0x01	; set bit 0 if this is a directory
.not_directory
	ld (hl),a	; set flags byte
	
	; advance dir to next entry
	call fatfs_dir_next
	
	scf	; signal success
	ld hl,1
	ret
	
.end_of_dir
	or a ; reset carry
	ld hl,0
	ret

.skip_entry
	push de
	call fatfs_dir_next
	pop de
	jr test_entry
	