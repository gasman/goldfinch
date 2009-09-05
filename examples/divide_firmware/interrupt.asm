XLIB interrupt

LIB keyscan_scan
LIB keyscan_key

.interrupt
	push af
	push bc
	push de
	push hl
	
	call keyscan_scan
	ld a,(keyscan_key)
	ld (0x5800),a
	
	pop hl
	pop de
	pop bc
	pop af
	ei
	ret