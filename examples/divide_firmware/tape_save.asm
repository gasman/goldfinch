XREF tape_save

LIB exit_ret

; do-nothing handler for the 'save bytes to tape' trap
	org 0x04c6
.tape_save
	ld hl,0x1f80	; matches instruction in ROM
.tape_save_nextaddr
	push hl
	ld hl,tape_save_nextaddr
	ex (sp),hl
	jp exit_ret
	