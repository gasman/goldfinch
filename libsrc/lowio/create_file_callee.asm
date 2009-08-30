; FILE *create_file(DIR *dir, char *filename, unsigned char access_mode)
XLIB create_file_callee
XDEF create_file_asmentry

include "lowio.def"

.create_file_callee
	pop iy	; get return address
	pop bc	; get access mode
	pop hl	; get filename
	ex (sp),iy	; get dir and restore return address
; enter with IY = dir handle, HL = null-terminated filename, C = access mode
.create_file_asmentry
	push hl	; save filename pointer
	; get address of fs driver in hl
	ld l,(iy + dir_filesystem + filesystem_driver)
	ld h,(iy + dir_filesystem + filesystem_driver + 1)
	
	IF fsdriver_create_file <> 0	; add on offset to the create_file entry point (if it's not zero)
		push bc
		ld bc,fsdriver_create_file
		add hl,bc
		pop bc
	ENDIF
	ex (sp),hl	; push return address and get filename into hl
	ret	; jump to create_file handler routine
