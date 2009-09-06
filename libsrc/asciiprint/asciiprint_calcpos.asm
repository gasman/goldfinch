XLIB asciiprint_calcpos

; enter with Y/X coords in BC, return with screen position in BC
.asciiprint_calcpos
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
	ret