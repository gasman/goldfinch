; FILE *trdos_open_dirent(DIRENT *dirent, unsigned char access_mode)
XLIB trdos_open_dirent

LIB trdos_dir_get_entry
LIB trdos_file_allocate

include	"../lowio/lowio.def"
include	"trdos.def"

; enter with hl = dirent, c = access mode
.trdos_open_dirent
	push hl
	call trdos_file_allocate
	ex de,hl ; get file handle in de
	pop hl
	
	push de ; save file ptr
	; copy dir struct from dirent to file
	ld bc,dir_size
	ldir
	
	pop iy ; file/dir/filesystem pointer in iy
	call trdos_dir_get_entry
	push hl
	pop ix ; pointer to on-disk dir entry in ix

	; populate block number
	ld l,(ix + trdos_dir_entry_start_track)
	ld h,0
	ld (iy + file_trdos_block_offset),h	; set block offset to 0

	add hl,hl	; block number = 16 * track number + sector number
	add hl,hl
	add hl,hl
	add hl,hl
	ld a,(ix + trdos_dir_entry_start_sector)
	or l
	ld (iy + file_trdos_block_number),a
	ld (iy + file_trdos_block_number + 1),h
	
	; populate sectors_left
	ld a,(ix + trdos_dir_entry_sector_count)
	ld (iy + file_trdos_blocks_remaining),1
	
	push iy
	pop hl
	scf
	ret
	