; int write_file(FSFILE *file, void *buf, unsigned int nbyte)
XLIB write_file_callee
XDEF write_file_asmentry

include "lowio.def"

.write_file_callee
	pop bc	; get return address
	pop de	; get nbyte
	pop hl	; get buf
	pop iy	; get file
	push bc	; restore return address
; Entry: IY = file, HL=address, DE=size (0==64K)
; IY preserved (a requirement of write_file handlers)
.write_file_asmentry
	push hl	; save buffer
	ld l,(iy + file_filesystem + filesystem_driver + 0)	; get pointer to filesystem driver in hl
	ld h,(iy + file_filesystem + filesystem_driver + 1)
	
	IF fsdriver_write_file <> 0	; add on offset to the write_file entry point (if it's not zero)
		push bc
		ld bc,fsdriver_write_file
		add hl,bc
		pop bc
	ENDIF
	ex (sp),hl	; restore buffer address and save jump address for write_file
	ret	; jump to write_file handler routine
