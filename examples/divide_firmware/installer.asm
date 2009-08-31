XLIB installer

	org 0x6000
	binary "firmware.bin"
.firmware_end
	defs 0x2000 - firmware_end ; seems that our addresses count from zero here. how annoying.
	ld hl,0x4000
	di
	call 0x1ffb	; RET and page out DivIDE
.wait_key
	in a,(0xfe)	; check for key
	cpl
	and 0x1f		; zero if none pressed
	jr z,wait_key
	ld a,0x83	; set CONMEM, and RAM page 3
	out (0xe3),a
.write_byte
	dec hl	; next byte
	bit 6,h	; if bit 6 of h is set, we're at 0xffff and have finished writing
	jr nz,done_writing	; not sure why we jump to the djnz instead of after it...
		; - but it's harmless enough (just means we waste a bit of time trying to read bytes at 0xffff)
	ld b,0x07	; retry reading bytes up to 0x07xx times
	ld a,b
	and l		; set A to the low 3 bits of L
	out (0xfe),a	; and use this to make a border stripe
	ld e,l		; build source address in DE
	ld a,0x60	; by OR-ing HL with 0x6000
	or h
	ld d,a
	ld a,(de)	; read byte of firmware
	ld (hl),a	; write to DivIDE ROM/RAM
.reread_byte
	cp (hl)		; try to read it back
	jr z,write_byte	; if successful, move on to next byte
	dec bc	; effectively slows down the counter in b
	inc b	; by a factor of 256...
.done_writing
	djnz reread_byte	; retry up to bc-256 times
	; give up writing (either because we're done, or we've been unable to reread)
	ld a,0x40	; set MAPRAM and RAM page 0
	out (0xe3),a
	ei
	ld c,h	; return value in bc
	ret
