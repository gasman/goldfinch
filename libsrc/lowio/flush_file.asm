; extern void __LIB__ __FASTCALL__ flush_file(FSFILE *file);
XLIB flush_file

include "lowio.def"

.flush_file
; enter with hl = file handle
	push hl
	pop iy
	ld l,(iy + filesystem_driver + 0)	; get pointer to fs driver in hl
	ld h,(iy + filesystem_driver + 1)
	IF fsdriver_flush_file <> 0	; add on offset to the read_byte entry point (if it's not zero)
		ld bc,fsdriver_flush_file
		add hl,bc
	ENDIF
	push hl
	ret	; jump to read_byte handler routine
