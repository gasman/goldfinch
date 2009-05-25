; CALLER linkage for function pointers

XLIB divide_read_sector
LIB divide_read_sector_callee
XREF ASMDISP_DIVIDE_READ_SECTOR_CALLEE

.divide_read_sector
	
	; stack contents: return addr, drive ID, sector number low, sector number high, buffer addr
	pop af
	pop hl
	exx
	pop de
	pop bc
	pop hl
	push hl
	push bc
	push de
	exx
	push hl
	push af
	ld a,l
	exx
	
	jp divide_read_sector_callee + ASMDISP_DIVIDE_READ_SECTOR_CALLEE

