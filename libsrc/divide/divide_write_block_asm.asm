; void __CALLEE__ divide_write_block_callee(BLOCK_DEVICE *device, void *buffer, unsigned long block_number)

XLIB divide_write_block_asm

include	"divide.def"

	; enter : hl = buffer address
	;         bcde = LBA sector number
	;         ix = pointer to BLOCK_DEVICE structure
	; exit  : carry set if successful
	; uses  : af, bc, de, hl, af'
	
.divide_write_block_asm
	ld a,20	; attempt read up to 20 times
.retry
	ex af,af'	;'
	push de
	push bc

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
	ld a,0x30	; WRITE SECTOR
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
	
	ld bc,0x00a3 ; C = data register, 0x00 = loop x256
	otir ; write first 256 bytes
	dec b
	dec b
	otir ; write only 254 bytes
	in a,(191) ; test write error before write last word to IDE
	outi
	outi ;write complette sector
	bit 3,a ;if DRQ=0 then sector is writed with errors (bouncing - early write sector data)
	pop bc
	pop de
	jr nz,success
	; program must reread same IDE sector if error is detected
	ex af,af'	;'
	dec a	; decrement retry counter
	jr nz,retry
	; too many failures; signal error
	or a	; reset carry flag
	ret
.success
	scf	; indicate success
	ret
