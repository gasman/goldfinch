XLIB tap_save_block_callee
XDEF tap_save_block_asm

LIB write_byte_asmentry
LIB write_file_asmentry

; extern void __LIB__ __CALLEE__ tap_save_block_callee(FSFILE *file, void *buf, unsigned int length, unsigned char block_type);

.tap_save_block_callee
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
.tap_save_block_asm
	push af	; save flag byte
	push de	; save block length
	push ix	; save start address
	push af	; save flag byte

	inc de	; we will write a flag byte and checksum in addition to the stated block length
	inc de
	push de	; save incremented block length - stack = fb bl sa fb ibl
	
	push hl	; get file handle into iy
	pop iy
	ld c,e	; get low byte of incremented block length into C
	call write_byte_asmentry	; write low byte of incremented block length

	pop de	; restore incremented block length - stack = fb bl sa fb
	ld c,d	; get high byte of incremented block length into C
	call write_byte_asmentry	; write high byte of incremented block length

	pop af	; restore flag byte - stack = fb bl sa
	ld c,a	; get flag byte into C
	call write_byte_asmentry	; write flag byte
	
	pop hl	; restore start address
	pop de	; restore data length - stack = fb
	push hl	; save start address
	push de	; save data length - stack = fb sa bl
	call write_file_asmentry	; write file data
	
	; calculate checksum
	pop bc	; restore data length
	pop hl	; restore start address
	pop af	; restore flag byte (initial value of checksum) - stack = empty
.calc_checksum
	xor (hl)	; merge data byte into checksum
	cpi	; inc hl, dec bc, set PO=true if BC=0
	jp pe,calc_checksum
	
	ld c,a	; get checksum byte into C
	jp write_byte_asmentry	; write checksum and exit
	