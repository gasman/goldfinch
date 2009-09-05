XLIB startup

LIB exit_jphl
LIB exit_ret
LIB exit_retn

LIB asciiprint_print
LIB asciiprint_setpos

	org 0x0000
; rst 0x0000: cold start
	di	; duplicates instruction in ROM
.rst00_continue
	ld bc,0x7ffd	; set register 
	jr do_reset
.rst00_end
	defs 0x0008 - rst00_end
; rst 0x0008: error handling
	ld hl,(0x5c5d)	; duplicates instruction in ROM
.rst08_continue
	push hl
	ld hl,rst08_continue	; set return address to the next ROM instruction
	ex (sp),hl	; restore hl and push return address
	jp exit_ret
.rst08_end
	defs 0x0017 - rst08_end
; 0x0017: arrive here if we take the JR at 0x0066 (from an NMI occurring while DivIDE is paged in)
	ret	; a retriggered NMI while DivIDE is active should have no effect
.dividenmi_end
	defs 0x001f - dividenmi_end
; 0x001f: arrive here if we take the JR at 0x0038 (IM1 interrupt occurring while DivIDE is paged in);
; this is where we can put a DivIDE-specific interrupt handler
	ei
	ret
.divideint_end
	defs 0x0038 - divideint_end
; rst 0x0038: IM1 interrupt
	defb 0x18	; this combines with the following PUSH HL instruction to form JR 0x001f.
		; If we arrived here from the ROM trap, we will have just executed a PUSH AF
.rst38_continue
	push hl
	ld hl,rst38_continue	; set return address to the next ROM instruction
	ex (sp),hl	; restore hl and push return address
	jp exit_ret
.do_reset	; rst 00 handler continues here
	ld a,0x10	; 48K ROM enabled, paging active, page 0 paged in
	out (c),a	; force usr0 mode - otherwise entering usr0 in 128K Basic gets us stuck in a loop
	ld hl,rst00_continue	; set return address to the next ROM instruction
	jp exit_jphl	; and return there via firmware exit point
.rst38_end
	defs 0x0066 - rst38_end
; 0x0066: NMI
	defb 0x18 ; this combines with the following XOR A instruction to form JR 0x0017.
		; If we arrived here from the ROM trap, we will have just executed a PUSH AF
	xor a
	out (0xe3),a	; page in DivIDE RAM page 0 at 0x2000..0x3fff
	
	push hl
	push de
	push bc
	
	ld bc,0
	call asciiprint_setpos
	ld hl,nmi_message
	call asciiprint_print
	
	pop bc
	pop de
	pop hl
	
	pop af	; restore af
	jp exit_ret	; retn would probably be more correct, but it's a two byte instruction
		; which means we'll end up paging out half way through it. I suspect there's no
		; meaningful difference...
	
.nmi_message
	defm "ping!"
	defb 0