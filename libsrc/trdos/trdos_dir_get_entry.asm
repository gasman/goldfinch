XLIB trdos_dir_get_entry

LIB buffer_findbuf

include	"../lowio/lowio.def"

; enter with IY = pointer to dir struct
; return with HL = pointer to on-disk dir entry
; preserves IY
.trdos_dir_get_entry
	; get block device into ix
	ld l,(iy + dir_filesystem + filesystem_trdos_block_device)
	ld h,(iy + dir_filesystem + filesystem_trdos_block_device + 1)
	push hl
	pop ix
	
	push iy
	
	; set bcde to block number
	ld b,0
	ld c,b
	ld d,(iy + dir_trdos_block_number + 1)
	ld e,(iy + dir_trdos_block_number)
	call buffer_findbuf	; now hl = start of sector buffer
	ld c,(iy + dir_trdos_block_offset)
	ld b,0
	add hl,bc	; add offset to move hl to start of directory record
	
	pop iy
	ret
