; void trdos_open_dirent(DIRENT *dirent, FILE *file)
XLIB trdos_open_dirent

include	"../lowio/lowio.def"

; enter with ix = dirent, de = file
.trdos_open_dirent
	ld l,(ix + dirent_dir_ptr)
	ld h,(ix + dirent_dir_ptr + 1)
	push de
	; copy filesystem struct to file
	ld bc,filesystem_size
	ldir
	pop iy	; file ptr in iy
	
	; populate block number
	ld l,(ix + dirent_trdos_start_track)
	ld h,0

	ld (iy + file_trdos_block_offset),h	; set block offset to 0

	add hl,hl	; block number = 16 * track number + sector number
	add hl,hl
	add hl,hl
	add hl,hl
	ld a,(ix + dirent_trdos_start_sector)
	or l
	ld (iy + file_trdos_block_number),a
	ld (iy + file_trdos_block_number + 1),h
	
	; populate sectors_left
	ld a,(ix + dirent_trdos_sector_count)
	ld (iy + file_trdos_blocks_remaining),1
	ret
	