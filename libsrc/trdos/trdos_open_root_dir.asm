; void trdos_open_root_dir(FILESYSTEM *fs, DIR *dir) - open the root directory of the filesystem
XLIB trdos_open_root_dir

include	"../lowio/lowio.def"
include	"trdos.def"

; enter with hl = filesystem, de = dir
.trdos_open_root_dir
	push de
	; first make a copy of the filesystem object
	ld bc,filesystem_size
	ldir

	pop ix
	; reset the block number and offset to 0
	xor a
	ld (ix + dir_fs_data + trdos_dir_block_number),a
	ld (ix + dir_fs_data + trdos_dir_block_number + 1),a
	ld (ix + dir_fs_data + trdos_dir_block_offset),a
	ret
	