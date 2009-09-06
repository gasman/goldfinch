XLIB interrupt

LIB keyscan_scan

.interrupt
	push af
	push bc
	push de
	push hl
	
	call keyscan_scan
	
	pop hl
	pop de
	pop bc
	pop af
	ei
	ret