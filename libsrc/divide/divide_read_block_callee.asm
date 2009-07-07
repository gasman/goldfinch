; void __CALLEE__ divide_read_block_callee(BLOCK_DEVICE *device, void *buffer, unsigned long block_number)

XLIB divide_read_block_callee
XDEF ASMDISP_DIVIDE_READ_BLOCK_CALLEE

include	"divide.def"

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
	
.asmentry
	; get drive ID byte (contributes bits 4 and 6 of the "LBA bits 24..28 + drive" register)
	ld a,(ix + divide_blockdev_driveid)
	or b
	out (0xbb),a	; LBA bits 24..28 + drive (bit 4) + LBA flag (bit 6)
	ld a,e
	out (0xaf),a	; LBA bits 0..7
	ld a,d
	out (0xb3),a	; LBA bits 8..15
	ld a,c
	out (0xb7),a	; LBA bits 16..23
	
	ld a,1
	out (0xab),a	; read one sector
	ld a,0x20	; READ SECTOR
	out (0xbf),a	; command reg

	; wait for ready response
.wait_ready
	in a,(0xbf)	; wait for 'ready' status
	and 0x80	; test bit 7
	jr nz,wait_ready
	
	; check for error
	in a,(0xa7)	; error reg
	and 0x10	; if bit 4 set, error occurred
	ret nz	; exit with carry reset
	
	ld bc,0x00a3	; C = data register, 0x00 = loop x256
	inir	; inir twice to read 512 bytes
	inir

	scf	; indicate success
	ret

DEFC ASMDISP_DIVIDE_READ_BLOCK_CALLEE = asmentry - divide_read_block_callee
