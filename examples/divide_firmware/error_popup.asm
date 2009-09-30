XLIB error_popup

LIB dirtywindow_rect
LIB asciiprint_print
LIB asciiprint_setpos
LIB errors_get_message

; enter with A = error code to show

.error_popup
	push af
	ld bc,0x0a00
	ld de,0x0320
	call dirtywindow_rect
	ld bc,0x0b01
	call asciiprint_setpos
	pop af
	call errors_get_message	; returns error message in HL
	call asciiprint_print
	; wait for key - can't run keyscan_wait_key, as interrupts may be disabled
.wait_key
	ld bc,0x00fe
	in a,(c)
	cpl
	and 0x1f
	jr z,wait_key
	ret
	