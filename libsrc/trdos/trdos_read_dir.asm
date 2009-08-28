; int trdos_read_dir(DIR *dir, DIRENT *dirent) - read the next entry from a directory
XLIB trdos_read_dir

LIB trdos_dir_get_entry
LIB trdos_dir_next

include	"../lowio/lowio.def"

; enter with iy = dir, de = dirent
; returns 0 if end of dir
.trdos_read_dir

	push de ; save dirent
	call trdos_dir_get_entry ; get pointer to on-disk dir entry into hl
	pop de ; restore dirent
	
	ld a,(hl)
	or a	; if first byte of record is 0, end of dir
	jr z,end_of_dir

	; TODO: recognise deleted dir entries (is there such a thing in trdos?) and skip them

	push hl	; store pointer to on-disk dir entry
	
	push de ; get pointer to dirent struct into ix
	pop ix
	
	push iy	; get pointer to dir struct into hl
	pop hl
	ld bc,dir_size ; copy the dir struct to start of dirent
	ldir
	
	pop hl ; restore pointer to on-disk dir entry
	ld bc,8	; copy filename to dirent
	ldir
	; rewind to the last non-space character
.remove_trailing_space
	dec de
	ld a,(de)
	cp ' '
	jr z,remove_trailing_space
	; place a dot after it
	inc de
	ld a,'.'
	ld (de),a
	; and add the extension character
	inc de
	ldi
	; then null-terminate
	xor a
	ld (de),a
	
	ld (ix + dirent_flags),a	; clear flags
	
	; advance block offset/number in original directory record
	call trdos_dir_next

	scf	; signal success
	ld hl,1
	ret
.end_of_dir
	ld hl,0
	ret
