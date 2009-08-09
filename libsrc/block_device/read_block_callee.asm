; void __CALLEE__ read_block_callee(BLOCK_DEVICE *device, void *buffer, unsigned long block_number)

XLIB read_block_callee
XDEF read_block_asm

include	"block_device.def"

.read_block_callee

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
.read_block_asm
	push hl	; save buffer address
	ld l,(ix + blockdev_driver + 0)	; get pointer to device driver in hl
	ld h,(ix + blockdev_driver + 1)
	
	IF blockdevdriver_read_block <> 0	; add on offset to the read_block entry point (if it's not zero)
		push de
		ld de,blockdevdriver_read_block
		add hl,de
		pop de
	ENDIF
	ex (sp),hl	; recall buffer address; push address of read_block handler in its place
	ret	; jump to read_block handler routine
