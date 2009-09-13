; int seek_file(FILE *file, unsigned long pos)
XLIB seek_file_callee
XDEF seek_file_asmentry
XDEF ASMDISP_SEEK_FILE_CALLEE

include "lowio.def"

.seek_file_callee
	pop bc	; get return address
	pop hl	; get pos (low)
	pop de	; get pos (high)
	pop iy	; get file
	push bc
; enter with: IY = file, DEHL = pos
.seek_file_asmentry
	push hl	; save pos(low)
	ld l,(iy + file_filesystem + filesystem_driver + 0)	; get pointer to filesystem driver in hl
	ld h,(iy + file_filesystem + filesystem_driver + 1)
	
	IF fsdriver_seek_file <> 0	; add on offset to the read_file entry point (if it's not zero)
		ld bc,fsdriver_seek_file
		add hl,bc
	ENDIF
	ex (sp),hl	; push return address and restore pos(low)
	ret	; jump to seek_file handler routine

DEFC ASMDISP_SEEK_FILE_CALLEE = seek_file_asmentry - seek_file_callee
