XLIB asciiprint_newline

LIB asciiprint_position

.asciiprint_newline
	ld a,(asciiprint_position)	; get low byte of cursor
	and 0xe0	; set x coord to 0
	add a,0x20	; increment y coord
	ld (asciiprint_position),a
	ret nc	; we're done, unless we moved to next screen third
	ld a,(asciiprint_position + 1)
	add a,0x08
		; TODO: handle bottom-of-screen overflow
	ld (asciiprint_position + 1),a
	ret
