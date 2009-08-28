XLIB trdos_dir_next

include	"../lowio/lowio.def"

; enter with IY = pointer to dir struct
; increment dir pointer to next entry (NB not necessarily a valid one - may be end of dir or a blank entry)
.trdos_dir_next
	ld a,(iy + dir_trdos_block_offset)
	add a,16	; entries are 16 bytes
	ld (iy + dir_trdos_block_offset),a
	ret nc	; still in same sector, so we're done

	ld b,(iy + dir_trdos_block_number + 1)
	ld c,(iy + dir_trdos_block_number)
	inc bc
	ld (iy + dir_trdos_block_number + 1),b
	ld (iy + dir_trdos_block_number),c
	ret
