; extern void __LIB__ __FASTCALL__ dir_home(DIR *dir);
XLIB dir_home

include "lowio.def"

.dir_home
; enter with hl = file handle
	push hl
	pop iy
	ld l,(iy + filesystem_driver + 0)	; get pointer to fs driver in hl
	ld h,(iy + filesystem_driver + 1)
	IF fsdriver_dir_home <> 0	; add on offset to the dir_home entry point (if it's not zero)
		ld bc,fsdriver_dir_home
		add hl,bc
	ENDIF
	push hl
	ret	; jump to dir_home handler routine
