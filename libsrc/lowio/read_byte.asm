; extern unsigned char __LIB__ __FASTCALL__ read_byte(FSFILE *file);
XLIB read_byte

include "lowio.def"

.read_byte
; enter with hl = file handle
	push hl
	pop iy
	ld l,(iy + filesystem_driver + 0)	; get pointer to fs driver in hl
	ld h,(iy + filesystem_driver + 1)
	IF fsdriver_read_byte <> 0	; add on offset to the dir_home entry point (if it's not zero)
		ld bc,fsdriver_read_byte
		add hl,bc
	ENDIF
	push hl
	ret	; jump to read_byte handler routine
