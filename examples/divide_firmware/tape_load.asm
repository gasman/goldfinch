XREF tape_load

LIB exit_ret

; do-nothing handler for the 'load bytes from tape' trap
	org 0x0562
.tape_load
	in a,(0xfe)	; matches instruction in ROM
.tape_load_nextaddr
	push hl
	ld hl,tape_load_nextaddr
	ex (sp),hl
	jp exit_ret
	