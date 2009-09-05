XLIB clear_screen

.clear_screen
	ld hl,0x4000
	ld de,0x4001
	ld bc,0x1800
	ld (hl),l
	ldir
	ld (hl),0x38
	ld bc,0x02ff
	ldir
	ret
	