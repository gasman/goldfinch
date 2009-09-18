XLIB page_0_hooks

LIB exit_jphl
LIB exit_ret
LIB exit_ei_ret

LIB nmi
LIB interrupt
LIB startup

LIB reg_store_iff
LIB reg_store_im
LIB reg_store_r
LIB reg_store_i
LIB reg_store_sp
LIB reg_store_main
LIB reg_store_end

LIB nmi_final_ret

	org 0x0000
; rst 0x0000: cold start
	di	; duplicates instruction in ROM
.rst00_continue
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
	jp interrupt
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
	ld sp,0x0000	; put SP somewhere usable
	call startup
	ld hl,rst00_continue	; set return address to the next ROM instruction
	jp exit_jphl	; and return there via firmware exit point
.rst38_end
	defs 0x0066 - rst38_end
; 0x0066: NMI
	defb 0x18 ; this combines with the following XOR A instruction to form JR 0x0017.
		; If we arrived here from the ROM trap, we will have just executed a PUSH AF
	; Following handler is "borrowed" from FATware (thanks Baze!)
	xor a	; DivIDE page 0 (where all the register state will be stored)
	out (0xe3),a

	ld a,r
	rlca	; preserve top bit of R
	sub 0x0c	; compensate for R being incremented by the instructions above
	rrca
	ld (reg_store_r),a	; save R
	ld a,i	; as a side effect, sets the PV flag to 1 = EI, 0 = DI
	ld (reg_store_i),a	; save I
	ld a,0x00
	jp po,interrupt_is_di
	inc a	; set a=1 to indicate EI
.interrupt_is_di
	ld (reg_store_iff),a
	pop af	; corresponds to the 'push af' at the start of the main ROM's NMI routine
	ld (reg_store_sp),sp	; save SP
	ld sp,reg_store_end
	; push all standard registers
	push af
	push bc
	push de
	push hl
	ex af,af'
	exx
	push af
	push bc
	push de
	push hl
	push ix
	push iy
	
	ld sp,0x4000	; place SP at top of DivIDE RAM
	; TODO: save / silence AY registers
	ld a,0x3d	; point I at our test interrupt vector table
	ld i,a
	xor a
	ei	; allow one interrupt to happen;
	halt	; IM2 routine will increment A to 1 if IM2 is running
	di
	ld (reg_store_im),a
	im 1	; set up interrupts as IM1 for firmware operation
	
	call nmi
	; NMI routine is expected to return with interrupts disabled,
	; DivIDE page 0 paged in, and screen restored as appropriate

	ld a,(reg_store_i)	; restore I
	ld i,a
	ld a,(reg_store_im)	; restore IM
	im 1
	or a
	jr z,restore_as_im1
	im 2	; set im2 if reg_store_im contained 1
.restore_as_im1
	ld a,(reg_store_iff)
	or a
	ld hl,exit_ei_ret
	jr nz,exit_with_ei
	inc l	; if reg_store_iff was zero, skip the EI instruction to keep interrupts disabled
.exit_with_ei
	ld a,0xc3	; opcode for JP
	ld (nmi_final_ret),a	; write the appropriate JP instruction to exit_ei_ret
	ld (nmi_final_ret + 1),hl	; or exit_ret
	
	ld sp,reg_store_main
	; restore main registers
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	pop af
	ex af,af'
	exx
	pop hl
	pop de
	pop bc
	pop af
	ld sp,(reg_store_sp)	; restore sp
	jp nmi_final_ret	; jump to the final exit point
