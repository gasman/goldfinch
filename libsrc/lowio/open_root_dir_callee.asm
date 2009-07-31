; void open_root_dir(FILESYSTEM *fs, DIR *dir) - open the root directory of the filesystem
XLIB open_root_dir_callee
XDEF open_root_dir_asmentry
XDEF ASMDISP_OPEN_ROOT_DIR_CALLEE

include "lowio.def"

.open_root_dir_callee
	pop hl	; return address
	pop de	; dir
	ex (sp),hl	; get fs and replace return address
; enter with hl = filesystem, de = dir
.open_root_dir_asmentry
	push hl	; save fs address
	push hl
	pop ix	; get fs into ix
	ld l,(ix + filesystem_driver + 0)	; get pointer to fs driver in hl
	ld h,(ix + filesystem_driver + 1)
	
	IF fsdriver_open_root_dir <> 0	; add on offset to the open_root_dir entry point (if it's not zero)
		ld bc,fsdriver_open_root_dir
		add hl,bc
	ENDIF
	ex (sp),hl	; recall fs address; push address of open_root_dir handler in its place
	ret	; jump to open_root_dir handler routine


DEFC ASMDISP_OPEN_ROOT_DIR_CALLEE = open_root_dir_asmentry - open_root_dir_callee
