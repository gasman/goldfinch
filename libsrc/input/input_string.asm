XLIB input_string

LIB asciiprint_setpos
LIB asciiprint_putchar
LIB asciiprint_backspace
LIB keyscan_wait_key

; enter with BC = screen position (X/Y), HL = input buffer to fill
; returns with:
; carry reset if cancelled with BREAK
; carry set if submitted with ENTER, and buffer at HL containing null-terminated string

; NOTE: Completely vulnerable to buffer overflows...

.input_string
	call asciiprint_setpos
.next_char
	call keyscan_wait_key
	cp 0x1b	; break
	ret z	; return with carry reset
	cp 0x0c	; delete
	jr z,delete
	cp 0x0d	; enter
	jr z,exit
	cp ' '	; only permit printable characters (' ' and higher)
	jr c,next_char
	ld (hl),a
	inc hl
	push hl
	call asciiprint_putchar
	pop hl
	jr next_char
.exit
	ld (hl),0	; null-terminate
	scf
	ret
.delete	; TODO: guard against deleting past the start
	dec hl
	push hl
	call asciiprint_backspace
	ld a,' '; overwrite last character with space
	call asciiprint_putchar
	call asciiprint_backspace
	pop hl
	jr next_char
	