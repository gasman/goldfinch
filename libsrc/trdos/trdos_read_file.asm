; int trdos_read_file(FILE *file, void *buf, unsigned int nbyte)
XLIB trdos_read_file

include	"../lowio/lowio.def"

LIB buffer_findbuf

; enter with: IX = file, DE = buf, BC = nbyte
; returns hl=0 and carry reset if end of file
.trdos_read_file
	; test for end of file (= blocks_remaining == 0)
	ld a,(ix + file_trdos_blocks_remaining)
	or a
	jr z,exit_eof

	; return if no more bytes left to read; shortcut to avoid redundantly reading next sector
	ld a,b
	or c
	jr z,exit_ok

	; read sector into buffer
	push bc
	push de

	; read sector number into BCDE
	ld bc,0
	ld d,(ix + file_trdos_block_number + 1)
	ld e,(ix + file_trdos_block_number)

	; get block device handle into IX
	push ix
	ld l,(ix + file_filesystem + filesystem_data)
	ld h,(ix + file_filesystem + filesystem_data + 1)
	push hl
	pop ix
	
	call buffer_findbuf
	; now hl = pointer to sector buffer
	; add file_trdos_block_offset to get to the file data position
	pop ix	; restore file pointer
	ld e,(ix + file_trdos_block_offset)
	ld d,0
	add hl,de

	; restore user buffer / byte count
	pop de
	pop bc
	
.copy_loop
	ldi	; copy byte to user buffer
	inc (ix + file_trdos_block_offset)
	jr z,next_sector	; if offset overflows to 0, advance to next sector
	; otherwise, test for bc=0
	ld a,b
	or c
	jp nz,copy_loop
.exit_ok
	ld hl,1
	scf
	ret
	
.next_sector
	dec (ix + file_trdos_blocks_remaining)
	inc (ix + file_trdos_block_number)
	jr nz,trdos_read_file
	inc (ix + file_trdos_block_number + 1)
	jr trdos_read_file

.exit_eof
	ld hl,0
	ret

