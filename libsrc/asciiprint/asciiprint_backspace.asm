XLIB asciiprint_backspace

LIB asciiprint_position

; move current print position back one character
.asciiprint_backspace
	ld hl,(asciiprint_position)
	rr h
	rr h
	rr h
	dec hl
	rl h
	rl h
	rl h
	; check we're not backspacing past the start of the screen
	ld a,h
	cp 0x40
	ret c
	ld (asciiprint_position),hl
	ret