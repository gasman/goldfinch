XLIB exit
XDEF exit_ret
XDEF exit_jphl

; Firmware exit points: instructions in 0x1ff8 - 0x1fff will page out the DivIDE after execution
	org 0x1ffb
.exit_ret
	ret	; matches the RET in the ROM at 0x1ffb. Not sure if that's strictly necessary, but can't hurt
		; (and I *think* the standard flashing routine expects it)
.exit_jphl
	jp (hl)
