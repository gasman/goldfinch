; void trdos_open_dirent(DIRENT *dirent, FILE *file)
XLIB open_dirent_callee
XDEF open_dirent_asmentry
XDEF ASMDISP_OPEN_DIRENT_CALLEE

include "lowio.def"

.open_dirent_callee
	pop ix	; get return address
	pop de	; get file
	ex (sp),ix	; get dirent and restore return address
; enter with ix = dirent, de = file
.open_dirent_asmentry
	ld l,(ix + dirent_dir_ptr + 0)	; get pointer to dir (and thus filesystem) in iy
	ld h,(ix + dirent_dir_ptr + 1)
	push hl
	pop iy
	; get pointer to fs driver in hl
	ld l,(iy + dir_filesystem + filesystem_driver)
	ld h,(iy + dir_filesystem + filesystem_driver + 1)
	
	IF fsdriver_open_dirent <> 0	; add on offset to the read_dir entry point (if it's not zero)
		ld bc,fsdriver_open_dirent
		add hl,bc
	ENDIF
	push hl
	ret	; jump to read_dir handler routine

DEFC ASMDISP_OPEN_DIRENT_CALLEE = open_dirent_asmentry - open_dirent_callee
