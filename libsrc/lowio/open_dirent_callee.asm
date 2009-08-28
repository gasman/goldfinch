; void open_dirent(DIRENT *dirent, FILE *file, unsigned char access_mode)
XLIB open_dirent_callee
XDEF open_dirent_asmentry
XDEF ASMDISP_OPEN_DIRENT_CALLEE

include "lowio.def"

.open_dirent_callee
	pop ix	; get return address
	pop bc	; get access mode
	pop de	; get file
	ex (sp),ix	; get dirent and restore return address
; enter with ix = dirent, de = file, c = access mode
.open_dirent_asmentry
	; get address of fs driver in hl
	ld l,(ix + dirent_dir + dir_filesystem + filesystem_driver)
	ld h,(ix + dirent_dir + dir_filesystem + filesystem_driver + 1)
	
	IF fsdriver_open_dirent <> 0	; add on offset to the open_dirent entry point (if it's not zero)
		push bc
		ld bc,fsdriver_open_dirent
		add hl,bc
		pop bc
	ENDIF
	push ix ; push dirent
	ex (sp),hl	; push return address and get dirent into hl
	ret	; jump to open_dirent handler routine

DEFC ASMDISP_OPEN_DIRENT_CALLEE = open_dirent_asmentry - open_dirent_callee
