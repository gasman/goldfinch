XLIB check_file_extension

; enter with HL = pointer to null-terminated filename,
;   DE = extension to test (in capitals, null terminated, without the dot).
; Return carry set iff the filename has the specified extension

.check_file_extension
	push de
.save_extension_pos
	ld d,h
	ld e,l
.check_char
	ld a,(hl)
	or a
	jr z,end_of_filename
	cp '.'
	inc hl
	jr z,save_extension_pos	; if it was a dot, record the next address (now in HL) in de
	jr check_char
.end_of_filename	; extension is now in DE - compare it against the test extension
	pop hl	; HL = extension to test against
.compare
	ld a,(de)
	cp (hl)
	jr nz,match_failed
	or a	; end comparison (with success) if A=0
	inc hl
	inc de
	jr nz,compare
	scf
	ret
.match_failed
	or a	; reset carry flag
	ret
