XLIB keyscan_scan

; Scan keyboard, and save pseudo-ASCII key code in keyscan_key

LIB keyscan_key
LIB keyscan_last_key
LIB keyscan_delay_count
LIB keyscan_table_unshifted
LIB keyscan_table_symshift
LIB keyscan_table_capsshift

include "keyscan.def"

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
	ld d,a	; store test bitmap in D while we check that the key code in E isn't a shift key
	ld a,e
	cp 1	; caps shift
	jr z,key_is_shift
	cp 37	; sym shift
	jr z,key_is_shift
	jr key_found
.key_is_shift
	ld a,d	; resume testing with next bit
	jr test_bit
.next_row
	rlc b
	jr c,scan_row	; stop when the 0 bit reaches the carry flag
	ld e,0	; no key found
.key_found
	; has key changed since last interrupt?
	ld a,(keyscan_last_key)
	cp e
	jr nz,new_key
	; if not, only register keypress if keyscan_delay_count is zero
	ld a,(keyscan_delay_count)
	or a
	jr z,repeat_key
	; not zero, so decrement it this time
	dec a
	ld (keyscan_delay_count),a
	xor a	; no key returned
	ld (keyscan_key),a
	ret
.repeat_key
	ld a,keyscan_repeat_time	; ignore repeats of this key code
	ld (keyscan_delay_count),a	; until 'keyscan_repeat_time' frames have elapsed
	jr translate_key
.new_key
	ld a,e
	ld (keyscan_last_key),a	; remember this key code
	ld a,keyscan_debounce_time	; ignore repeats of this key code
	ld (keyscan_delay_count),a	; until 'keyscan_debounce_time' frames have elapsed
.translate_key
	; Is symbol shift pressed?
	ld hl,keyscan_table_symshift
	ld b,0x7f
	in a,(c)
	and 0x02
	jr z,lookup
	; Is caps shift pressed
	ld hl,keyscan_table_capsshift
	ld b,0xfe
	in a,(c)
	and 0x01
	jr z,lookup
	; No shift, so look up key code in keyscan_table_unshifted
	ld hl,keyscan_table_unshifted
.lookup
	ld d,0
	add hl,de
	ld a,(hl)
	ld (keyscan_key),a
	ret
	