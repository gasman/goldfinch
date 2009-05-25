; void __CALLEE__ divide_read_sector_callee(void *buffer, unsigned long sector_number, unsigned char drive_number)

XLIB divide_read_sector_callee
XDEF ASMDISP_DIVIDE_READ_SECTOR_CALLEE

.divide_read_sector_callee

	pop hl
	pop de
	ld a,e
	pop de
	pop bc
	ex (sp),hl
	
	; enter : hl = buffer address
	;         bcde = LBA sector number
	;         a = drive ID code (DIVIDE_DRIVE_MASTER or DIVIDE_DRIVE_SLAVE)
	; exit  : carry set if successful
	; uses  : af, bc, de, hl
	
.asmentry
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

DEFC ASMDISP_DIVIDE_READ_SECTOR_CALLEE = asmentry - divide_read_sector_callee
