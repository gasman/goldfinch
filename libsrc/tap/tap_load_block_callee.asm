XLIB tap_load_block_callee
XDEF tap_load_block_asm

LIB read_byte
LIB get_file_pos
LIB seek_file_asmentry
LIB read_file_asmentry

; extern void __LIB__ __CALLEE__ tap_load_block_callee(FSFILE *file, void *buf, unsigned int length, unsigned char block_type);

.tap_load_block_callee
	pop hl	; get return address
	pop bc	; get block_type
	pop de	; get length
	pop ix	; get buffer address
	ex (sp),hl	; get file handle and restore return address
	ld a,c	; move block_type into A
	
	; enter with:
	; DE = length of block
	; A = 0x00 for header, 0xff for data block
	; IX = start address
	; HL = file handle
	; Returns carry set on success, reset on failure
.tap_load_block_asm
	push de	; save requested length
	push ix	; save buffer address
	push af	; save block_type - stack = rl ba bt

	; get next block length from TAP file
	push hl	; save file handle - stack = rl ba bt fh
	call read_byte
	ex (sp),hl	; save low byte, restore file handle - stack = rl ba bt bll
	push hl	; save file handle - stack = rl ba bt bll fh
	call read_byte
	ld d,l
	pop hl	; restore file handle - stack = rl ba bt bll
	pop bc	; restore low byte - stack = rl ba bt
	ld e,c	; now de = actual block length

	; calculate file position advanced by block length
	push hl	; save file handle - stack = rl ba bt fh
	push de	; save actual block length - stack = rl ba bt fh bl
	call get_file_pos	; get TAP file position into DEHL
	pop bc	; restore actual block length - stack = rl ba bt fh
	add hl,bc	; add actual block length to file position
	jr nc,filepos_nocarry
	inc de	; deal with overflow into top word
.filepos_nocarry
	; put final TAP position at bottom of stack, as setting it will be the last thing we do
	pop iy	; restore file handle - stack = rl ba bt
	pop af	; restore block type - stack = rl ba
	pop ix	; restore buffer address - stack = rl
	ex (sp),hl	; restore requested length, save file pos low word - stack = fpl
	push de	; save file pos (high word) - stack = fpl fph
	push ix	; save buffer address - stack = fpl fph ba
	push iy	; save file handle - stack = fpl fph ba fh
	push hl	; save requested length - stack = fpl fph ba fh rl
	push bc	; save actual block length - stack = fpl fph ba fh rl bl
	push af	; save block type - stack = fpl fph ba fh rl bl bt
	
	; get file handle into HL
	push iy
	pop hl
	; check whether the requested block type matches the actual one
	call read_byte
	pop af	; recall requested block type - stack = fpl fph ba fh rl bl
	cp l
	jr nz,wrong_block_type
	
	pop hl	; get actual block length - stack = fpl fph ba fh rl
	dec hl
	dec hl	; compensate for the block_type and checksum bytes which don't count towards requested length
	pop de	; get requested block length - stack = fpl fph ba fh
	or a	; reset carry flag for the following sbc
	sbc hl,de	; Check whether actual block length (after compensation) is big enough to satisfy
		; the request. If not, it will carry
	jr c,block_too_small
	
	; read the block to the requested length
	ld b,d
	ld c,e	; get request length into BC
	pop ix	; restore file handle; stack = fpl fph ba
	pop de	; restore buffer address; stack = fpl fph
	push ix	; stack = fpl fph fh
	call read_file_asmentry	; read block
	; TODO: verify checksum
	pop iy	; stack = fpl fph
	; get final file position and seek to it
	pop de	; stack = fpl
	pop hl	; stack = empty
	call seek_file_asmentry
	scf	; set carry flag to indicate success
	ret
	
.block_too_small
	; read the block to its actual length, then cheerfully error out
	add hl,de	; restore hl to the actual block length
	inc hl	; and we'll be reading the checksum byte as data too
	ld b,h
	ld c,l	; get block length into BC
	pop iy	; restore file handle; stack = fpl fph ba
	pop de	; restore buffer address; stack = fpl fph
	push iy	; stack = fpl fph fh
	call read_file_asmentry	; read block
	pop iy	; stack = fpl fph
	jr seek_then_error
	
.wrong_block_type
	; remove excess stuff from the stack
	pop hl	; stack = fpl fph ba fh rl
	pop hl	; stack = fpl fph ba fh
	pop iy	; get file handle - stack = fpl fph ba
	pop hl	; stack = fpl fph
.seek_then_error
	; get final file position and seek to it
	pop de	; stack = fpl
	pop hl	; stack = empty
	call seek_file_asmentry	; seek to new file position
	or a	; reset carry flag to indicate failure
	ret
