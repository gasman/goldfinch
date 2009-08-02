; void trdos_open_dirent(DIRENT *dirent, FILE *file)
XLIB trdos_open_dirent

include	"../lowio/lowio.def"
include	"trdos.def"

; enter with hl = dirent, de = file
.trdos_open_dirent
	push hl
	push de
	; copy filesystem struct to file
	ld bc,filesystem_size
	ldir
	pop iy	; file ptr in iy
	pop ix	; dirent ptr in ix
	
	; populate block number
	ld l,(ix + dirent_fs_data + trdos_dirent_start_track)
	ld h,0

	ld (iy + file_fs_data + trdos_file_block_offset),h	; set block offset to 0

	add hl,hl	; block number = 16 * track number + sector number
	add hl,hl
	add hl,hl
	add hl,hl
	ld a,(ix + dirent_fs_data + trdos_dirent_start_sector)
	or l
	ld (iy + file_fs_data + trdos_file_block_number),a
	ld (iy + file_fs_data + trdos_file_block_number),h
	
	; populate sectors_left
	ld a,(ix + dirent_fs_data + trdos_dirent_sector_count)
	ld (iy + file_fs_data + trdos_file_blocks_remaining),1
	ret
	