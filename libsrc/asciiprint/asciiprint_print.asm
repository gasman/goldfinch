XLIB asciiprint_print

LIB asciiprint_putchar

; print a null-terminated string, from address HL
.asciiprint_print
	ld a,(hl)
	or a
	ret z
	push hl
	call asciiprint_putchar
	pop hl
	inc hl
	jr asciiprint_print
	