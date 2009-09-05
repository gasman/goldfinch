; Handler for non-maskable interrupts (aka The Magic Button)
XLIB nmi

LIB asciiprint_print
LIB asciiprint_setpos

.nmi
	; save screen
	ld a,1
	out (0xe3),a	; page in DivIDE RAM page 1
	ld hl,0x4000
	ld de,0x2000
	ld bc,0x1b00
	ldir
	
	xor a
	out (0xe3),a	; page in DivIDE RAM page 0 at 0x2000..0x3fff
	
	; clear screen
	ld hl,0x4000
	ld de,0x4001
	ld bc,0x1800
	ld (hl),l
	ldir
	ld (hl),0x3f
	ld bc,0x02ff
	ldir
	
	ld bc,0
	call asciiprint_setpos
	ld hl,nmi_message
	call asciiprint_print
	
	; wait for space
.wait_space
	ld bc,0x7ffe
	in a,(c)
	and 1
	jr nz,wait_space
	
	; restore screen
	ld a,1
	out (0xe3),a
	ld hl,0x2000
	ld de,0x4000
	ld bc,0x1b00
	ldir
	
	ret
	
.nmi_message
	defm "ping!"
	defb 0
