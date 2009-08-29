; extern void __LIB__ __FASTCALL__ close_file(FSFILE *file);
XLIB close_file

include "lowio.def"

.close_file
; enter with hl = file handle
	push hl
	pop iy
	ld l,(iy + filesystem_driver + 0)	; get pointer to fs driver in hl
	ld h,(iy + filesystem_driver + 1)
	IF fsdriver_close_file <> 0	; add on offset to the read_dir entry point (if it's not zero)
		ld bc,fsdriver_close_file
		add hl,bc
	ENDIF
	push hl
	ret	; jump to read_dir handler routine
