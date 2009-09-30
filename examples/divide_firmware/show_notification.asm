XLIB show_notification

LIB dirtywindow_rect
LIB asciiprint_print
LIB asciiprint_setpos

; enter with HL = pointer to null-terminated message to show

.show_notification
	push hl
	ld bc,0x0a02
	ld de,0x031c
	call dirtywindow_rect
	ld bc,0x0b03
	call asciiprint_setpos
	pop hl
	call asciiprint_print
	; wait for key - can't run keyscan_wait_key, as interrupts may be disabled
.wait_key
	ld bc,0x00fe
	in a,(c)
	cpl
	and 0x1f
	jr z,wait_key
	ret
	