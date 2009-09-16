; extern unsigned long __LIB__ __FASTCALL__ get_file_pos(FSFILE *file);
XLIB get_file_pos

include "lowio.def"

.get_file_pos
; enter with hl = file handle
	push hl
	pop iy
	ld l,(iy + filesystem_driver + 0)	; get pointer to fs driver in hl
	ld h,(iy + filesystem_driver + 1)
	IF fsdriver_get_file_pos <> 0	; add on offset to the get_file_pos entry point (if it's not zero)
		ld bc,fsdriver_get_file_pos
		add hl,bc
	ENDIF
	push hl
	ret	; jump to get_file_pos handler routine
