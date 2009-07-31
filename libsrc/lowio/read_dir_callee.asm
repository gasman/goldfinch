; int read_dir(DIR *dir, DIRENT *dirent) - read the next entry from a directory
XLIB read_dir_callee
XDEF read_dir_asmentry
XDEF ASMDISP_READ_DIR_CALLEE

include "lowio.def"

.read_dir_callee
	pop hl	; get return address
	pop ix	; get dirent
	ex (sp),hl	; get dir and restore return address
; enter with hl = dir, ix = dirent
; returns 0 if end of dir
.read_dir_asmentry
	push hl	; store dir
	
	push hl
	pop iy	; get dir into iy
	ld l,(iy + filesystem_driver + 0)	; get pointer to fs driver in hl
	ld h,(iy + filesystem_driver + 1)
	IF fsdriver_read_dir <> 0	; add on offset to the read_dir entry point (if it's not zero)
		ld bc,fsdriver_read_dir
		add hl,bc
	ENDIF
	ex (sp),hl	; recall fs address; push address of read_dir handler in its place
	ret	; jump to read_dir handler routine

DEFC ASMDISP_READ_DIR_CALLEE = read_dir_asmentry - read_dir_callee
