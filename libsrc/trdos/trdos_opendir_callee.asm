; void __CALLEE__ trdos_opendir_callee(TRDOS_FILESYSTEM *fs, TRDOS_DIR *dir)

XLIB trdos_opendir_callee
XDEF ASMDISP_TRDOS_OPENDIR_CALLEE

LIB read_block_callee
XREF ASMDISP_READ_BLOCK_CALLEE

include "trdos.def"

.trdos_opendir_callee
	pop hl
	pop ix
	pop iy
	push hl

	; enter : hl = TRDOS_FILESYSTEM *fs
	;         de = TRDOS_DIR *dir
	; exit  : 
	; uses  : 
.asmentry
	; dir->block_number = 0;
	xor a
	ld (ix + trd_dir_block_number),a
	ld (ix + trd_dir_block_number + 1),a
	ld (ix + trd_dir_block_number + 2),a
	ld (ix + trd_dir_block_number + 3),a

	; dir->current_dir_entry = dir->block_buffer;
	push ix
	pop hl
	ld de,trd_dir_block_buffer
	add hl,de	; now hl points to block_buffer
	ld (ix + trd_dir_current_dir_entry), l
	ld (ix + trd_dir_current_dir_entry + 1),h
	
	; set ix to the block_device, in preparation for calling read_block
	ld e,(iy + trdfs_block_device)
	ld d,(iy + trdfs_block_device + 1)
	push de
	pop ix

	ld b,0	; set block number to 0
	ld c,b
	ld d,b
	ld e,b
	
	jp read_block_callee + ASMDISP_READ_BLOCK_CALLEE	; read_block
