; void __CALLEE__ divide_write_block_callee(BLOCK_DEVICE *device, void *buffer, unsigned long block_number)

XLIB divide_write_block_callee
LIB divide_write_block_asm

include	"divide.def"

.divide_write_block_callee

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
	jp divide_write_block_asm
