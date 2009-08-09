; void __CALLEE__ write_block_callee(BLOCK_DEVICE *device, void *buffer, unsigned long block_number)

XLIB write_block_callee
XDEF write_block_asm

include	"block_device.def"

.write_block_callee

	pop ix	; get return address
	pop de
	pop bc	; get block number
	pop hl	; get buffer address
	ex (sp),ix	; get device and restore return address
	
	; enter : hl = buffer address
	;         bcde = LBA sector number
	;         ix = pointer to BLOCK_DEVICE structure
	; exit  : carry set if successful
	; uses  : potentially anything, because it calls a child function...
.write_block_asm
	push hl	; save buffer address
	ld l,(ix + blockdev_driver + 0)	; get pointer to device driver in hl
	ld h,(ix + blockdev_driver + 1)
	
	IF blockdevdriver_write_block <> 0	; add on offset to the write_block entry point (if it's not zero)
		push de
		ld de,blockdevdriver_write_block
		add hl,de
		pop de
	ENDIF
	ex (sp),hl	; recall buffer address; push address of write_block handler in its place
	ret	; jump to write_block handler routine
