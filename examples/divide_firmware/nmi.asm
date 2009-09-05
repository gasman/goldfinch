; Handler for non-maskable interrupts (aka The Magic Button)
XLIB nmi

LIB asciiprint_print
LIB asciiprint_setpos

.nmi
	ld bc,0
	call asciiprint_setpos
	ld hl,nmi_message
	call asciiprint_print
	ret
	
.nmi_message
	defm "ping!"
	defb 0
