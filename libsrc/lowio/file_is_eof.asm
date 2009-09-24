; extern unsigned int __LIB__ __FASTCALL__ file_is_eof(FSFILE *file);
XLIB file_is_eof

include "lowio.def"

.file_is_eof
; enter with hl = file handle
	push hl
	pop iy
	ld l,(iy + filesystem_driver + 0)	; get pointer to fs driver in hl
	ld h,(iy + filesystem_driver + 1)
	IF fsdriver_file_is_eof <> 0	; add on offset to the file_is_eof entry point (if it's not zero)
		ld bc,fsdriver_file_is_eof
		add hl,bc
	ENDIF
	push hl
	ret	; jump to file_is_eof handler routine
