; Handler for non-maskable interrupts (aka The Magic Button)
XLIB nmi

LIB print_dir

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
	
	call print_dir
	
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
