XREF tape_load

LIB exit_ret
LIB current_tap_file
LIB tap_load_block_asm

; handler for the 'load bytes from tape' trap
	org 0x0562
.tape_load
	in a,(0xfe)	; matches instruction in ROM
.tape_load_nextaddr
	push hl

	xor a
	out (0xe3),a	; page in DivIDE RAM page 0 at 0x2000..0x3fff
	
	; if no TAP file is open, drop back to original ROM routine
	ld hl,(current_tap_file)
	ld a,h
	or l
	jr nz,tap_file_is_open
	; NB we're not bothered about preserving the value of A on return
	ld hl,tape_load_nextaddr
	ex (sp),hl
	jp exit_ret
	
.tap_file_is_open
	pop bc	; throw away stored value of hl
	ex af,af'	; restore block_type byte into A
	; TODO: recognise VERIFY (carry reset) as distinct from LOAD
	push iy	; ROM expects this to be preserved
	call tap_load_block_asm
	pop iy
	jp exit_ret
	