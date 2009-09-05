XLIB asciiprint_setpos

LIB asciiprint_position

; enter with Y/X coords in BC
; corrupts BC
.asciiprint_setpos
	; bc = 000yyyyy 000xxxxx
	sla c
	sla c
	sla c
	; bc = 000yyyyy xxxxx000
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	; bc = 000000yy yyyxxxxx
	sla b
	sla b
	sla b
	; bc = 000yy000 yyyxxxxx
	set 6,b
	; bc = 010yy000 yyyxxxxx
	ld (asciiprint_position),bc
	ret