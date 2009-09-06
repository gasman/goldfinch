XLIB asciiprint_setpos

LIB asciiprint_calcpos
LIB asciiprint_position

; enter with Y/X coords in BC
; corrupts BC
.asciiprint_setpos
	call asciiprint_calcpos
	ld (asciiprint_position),bc
	ret