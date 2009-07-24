; CALLER linkage for function pointers
; void divide_write_block_callee(BLOCK_DEVICE *device, void *buffer, unsigned long block_number)

XLIB divide_write_block
LIB divide_write_block_callee
XREF divide_write_block_asmentry

.divide_write_block
	
	; stack contents: return addr, block number low, block number high, buffer addr, device pointer
	pop af	; get return addr
	pop de	; get block number
	pop bc
	pop hl	; get buffer addr
	pop ix	; get device pointer
	push ix
	push hl
	push bc
	push de
	push af	; restore everything to be torn down by caller

	jp divide_write_block_asmentry + (divide_write_block_callee-divide_write_block_callee)
