XLIB keyscan_scan

; Scan keyboard, and save pseudo-ASCII key code in keyscan_key

LIB keyscan_key
LIB keyscan_last_key
LIB keyscan_repeat_count
LIB keyscan_table_unshifted

.keyscan_scan
	ld bc,0xfefe	; reset each bit of B in turn
	ld e,0	; key code counts up from 1 in E
.scan_row
	in a,(c)
	and 0x1f
	or 0x20
.test_bit
	srl a
	jr z,next_row
	inc e
	jr c,test_bit	; if carry set, the tested bit was set => key not pressed
	; TODO: test that the key code (in E) isn't a shift
	jr key_found
.next_row
	rlc b
	jr c,scan_row	; stop when the 0 bit reaches the carry flag
	ld e,0	; no key found
.key_found
	; TODO: apply shifts, process key bounce
	; Look up key code in keyscan_table_unshifted
	ld d,0
	ld hl,keyscan_table_unshifted
	add hl,de
	ld a,(hl)
	ld (keyscan_key),a
	ret
	