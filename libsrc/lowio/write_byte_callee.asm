; extern void __LIB__ __CALLEE__ write_byte_callee(FSFILE *file, unsigned char byte);
XLIB write_byte_callee
XDEF write_byte_asmentry

include "lowio.def"

.write_byte_callee
	pop hl	; get return address
	pop bc	; get byte
	pop iy	; get file
	push hl	; restore return address
; Entry: IY = file, C = byte
.write_byte_asmentry
	ld l,(iy + file_filesystem + filesystem_driver + 0)	; get pointer to filesystem driver in hl
	ld h,(iy + file_filesystem + filesystem_driver + 1)
	
	IF fsdriver_write_byte <> 0	; add on offset to the write_file entry point (if it's not zero)
		ld de,fsdriver_write_byte
		add hl,de
	ENDIF
	push hl	; save jump address for write_byte
	ret	; jump to write_byte handler routine
