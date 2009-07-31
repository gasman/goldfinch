; int trdos_read_dir(DIR *dir, DIRENT *dirent) - read the next entry from a directory
XLIB trdos_read_dir

LIB buffer_findbuf

include	"../lowio/lowio.def"
include	"trdos.def"

; enter with hl = dir, ix = dirent
; returns 0 if end of dir
.trdos_read_dir
	; first make a pointer to the dir (which is handily also a pointer to (a copy of) the filesystem).
	; NB this requires the calling code NOT to deallocate the dir before it's finished doing stuff
	; with this dirent (such as opening the file in question)...
	ld (ix + dirent_dir_ptr),l
	ld (ix + dirent_dir_ptr + 1),h
	
	; store dirent for later
	push ix

	; get pointer to the block device into ix
	push hl
	pop iy
	ld l,(iy + filesystem_data)	; for the trdos filesystem, the 'data' field is a pointer to the block_device
	ld h,(iy + filesystem_data + 1)
	push hl
	pop ix

	; set bcde to block number
	ld b,0
	ld c,b
	ld d,(iy + dir_fs_data + trdos_dir_block_number + 1)
	ld e,(iy + dir_fs_data + trdos_dir_block_number)
	call buffer_findbuf	; now hl = start of sector buffer
	ld c,(iy + dir_fs_data + trdos_dir_block_offset)
	ld b,0
	add hl,bc	; add offset to move hl to start of directory record
	
	; restore dirent
	pop de
	
	; check for end of dir
	ld a,(hl)
	or a
	jr z,end_of_dir	; return with carry reset if end of dir (indicated by an entry starting with 0)
	
	; TODO: recognise deleted dir entries (is there such a thing in trdos?) and skip them
	
	; advance block offset/number in directory record
	ld a,c
	add a,16	; entries are 16 bytes
	ld (iy + dir_fs_data + trdos_dir_block_offset),a
	jr nc,same_sector
	; need to advance to next sector
	ld b,(iy + dir_fs_data + trdos_dir_block_number + 1)
	ld c,(iy + dir_fs_data + trdos_dir_block_number)
	inc bc
	ld (iy + dir_fs_data + trdos_dir_block_number + 1),b
	ld (iy + dir_fs_data + trdos_dir_block_number),c
.same_sector
	
	;push de	; save dirent
	; copy filename to dir entry
	inc de
	inc de	; advance to the dirent_filename field
	ld bc,8
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
	
	; pop ix
	; TODO: define and populate the sector number fields which will allow us to open the file
	
	scf	; signal success
	ld hl,1
	ret
.end_of_dir
	ld hl,0
	ret
