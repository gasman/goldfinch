XREF tape_save

LIB exit_ret
LIB current_write_tap_file
LIB tap_save_block_asm
LIB flush_file

; handler for the 'save bytes to tape' trap
	org 0x04c6
.tape_save
	ld hl,0x1f80	; matches instruction in ROM
.tape_save_nextaddr
	push hl
	push af

	xor a
	out (0xe3),a	; page in DivIDE RAM page 0 at 0x2000..0x3fff

	; if no TAP file is open, drop back to original ROM routine
	ld hl,(current_write_tap_file)
	ld a,h
	or l
	jr nz,tap_file_is_open
	pop af	; restore AF
	ld hl,tape_save_nextaddr
	ex (sp),hl	; push return address and restore HL
	jp exit_ret

.tap_file_is_open
	pop af	; restore flag byte from AF
	pop bc	; throw away the PUSHed 0x1f80
	; we were invoked with IX = start address and DE = length,
	; as required by tap_save_block_asm
	push iy	; ROM expects this to be preserved
	call tap_save_block_asm
	ld hl,(current_write_tap_file)
	call flush_file	; commit changes to disk
	pop iy
	jp exit_ret
