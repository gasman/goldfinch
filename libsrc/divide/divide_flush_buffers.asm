XLIB divide_flush_buffers

; Flush DivIDE buffers to put system into a known state ready to accept commands.
; Also pages in DivIDE ram page 0
; Routine provided by Velesoft -http://www.worldofspectrum.org/forums/showthread.php?t=26213&page=5
.divide_flush_buffers
	ld bc,0x692b
	xor a
	out (0xe3),a ;set divide ram 0 + reset low/high (*)
.flush_loop
	dec bc ;Delay
	in a,(0xa3)
	in a,(0xa3) ;read full 16bit data = 2bytes (**)
	ld a,b
	or c
	jr nz,flush_loop
	ret

;(*) - After any access to non-data command block registers (rrr=1..7) or to divIDE
;control register, following DATA REGISTER access is considered to be ODD.
;Accesses outside divIDE ports cannot change the EVEN/ODD state. After reset or
;power-on, this state is unknown.

;(**) - read from data port is used for correct work if you break any software with direct access to ide ports (video players with multiple sector reading, etc....). If user load this video player and press NMI button, then divide system can access to IDE only after read all sectors. Same problem is in DEMFIR. My BIOS for DiviIDE use this code and work always correct.
