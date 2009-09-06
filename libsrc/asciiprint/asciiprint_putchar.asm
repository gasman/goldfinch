XLIB asciiprint_putchar
XDEF asciiprint_putbitmap

LIB asciiprint_position
LIB asciiprint_font

; enter with ASCII code in A
; Corrupts A, HL, DE, B
.asciiprint_putchar
	ld l,a
	ld h,0
	add hl,hl	; multiply by 8 to get address offset
	add hl,hl
	add hl,hl
	ld de,asciiprint_font - 0x100	; -0x100 to compensate for codes starting at 0x20
	add hl,de
; enter with HL pointing to 8x8 bitmap
; Corrupts A, HL, DE, B
.asciiprint_putbitmap
	ld de,(asciiprint_position)
	push de
	ld b,8
.copy_pix_line
	ld a,(hl)
	ld (de),a
	inc d
	inc hl
	djnz copy_pix_line
; advance cursor position
	pop hl
	rr h
	rr h
	rr h
	inc hl
	rl h
	rl h
	rl h
		; TODO: scroll screen and move cursor to start of line 23
		; when we reach the bottom of the screen (H = 0x58)
	ld (asciiprint_position),hl
	ret