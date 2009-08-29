; void open_subdir(DIRENT *dirent, DIR *dir)
XLIB open_subdir_callee
XDEF open_subdir_asmentry

include "lowio.def"

.open_subdir_callee
	pop hl	; return address
	pop de	; dir
	pop iy	; dirent
	push hl	; restore return address
; enter with IY = dirent, DE = destination dir
.open_subdir_asmentry
	ld l,(iy + filesystem_driver + 0)	; get pointer to fs driver in hl
	ld h,(iy + filesystem_driver + 1)
	
	IF fsdriver_open_subdir <> 0	; add on offset to the open_subdir entry point (if it's not zero)
		ld bc,fsdriver_open_subdir
		add hl,bc
	ENDIF
	push hl
	ret	; jump to open_subdir handler routine

