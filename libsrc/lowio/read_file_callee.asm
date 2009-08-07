; int read_file(FSFILE *file, void *buf, unsigned int nbyte)
XLIB read_file_callee
XDEF read_file_asmentry
XDEF ASMDISP_READ_FILE_CALLEE

include "lowio.def"

.read_file_callee
	pop ix	; get return address
	pop bc	; get nbyte
	pop de	; get buf
	ex (sp),ix	; get file and restore return address
; enter with: IX = file, DE = buf, BC = nbyte
; returns hl=0 and carry reset if end of file
.read_file_asmentry
	ld l,(ix + file_filesystem + filesystem_driver + 0)	; get pointer to filesystem driver in hl
	ld h,(ix + file_filesystem + filesystem_driver + 1)
	
	IF fsdriver_read_file <> 0	; add on offset to the read_file entry point (if it's not zero)
		push bc
		ld bc,fsdriver_read_file
		add hl,bc
		pop bc
	ENDIF
	push hl
	ret	; jump to read_read_file handler routine

DEFC ASMDISP_READ_FILE_CALLEE = read_file_asmentry - read_file_callee
