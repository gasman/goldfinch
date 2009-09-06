XLIB keyscan_wait_key

LIB keyscan_key

; Wait for a keypress, and return its pseudo-ASCII code in A.
; Requires keyscan_scan to be running in interrupts
; Preserves all other registers
.keyscan_wait_key
	halt
	ld a,(keyscan_key)
	or a
	jr z,keyscan_wait_key
	ret
	