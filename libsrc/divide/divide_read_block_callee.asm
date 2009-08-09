; void __CALLEE__ divide_read_block_callee(BLOCK_DEVICE *device, void *buffer, unsigned long block_number)

XLIB divide_read_block_callee
LIB divide_read_block_asm

.divide_read_block_callee
	pop ix	; get return address
	pop de
	pop bc	; get block number
	pop hl	; get buffer address
	ex (sp),ix	; get device and restore return address
	
	; enter : hl = buffer address
	;         bcde = LBA sector number
	;         ix = pointer to BLOCK_DEVICE structure
	; exit  : carry set if successful
	; uses  : af, bc, de, hl
	jp divide_read_block_asm
