XLIB mbr_has_boot_signature

LIB buffer_findbuf

; enter with HL = pointer to block device
; return HL=1 if device has a boot record signature, HL=0 if not
; return carry reset on error
.mbr_has_boot_signature
	push hl
	pop ix	; partition handle in ix
	ld b,0	; request sector 0
	ld c,b
	ld d,b
	ld e,b
	call buffer_findbuf	; returns address of sector data in HL
	ret nc	; return with carry reset if buffer_findbuf returns an error
	ld de,0x01fe	; MBR signature is at offset 0x01fe
	add hl,de
	ld b,(hl)	; get first byte of signature into B
	inc hl
	ld a,(hl)	; get second byte of signature into A
	ld hl,0	; 0 = test fails
	cp 0xaa
	scf	; indicate no error
	ret nz	; return failure if second byte != 0xaa
	ld a,b
	cp 0x55
	scf	; indicate no error
	ret nz	; return failure if first byte != 0x55
	inc hl	; HL=1 to indicate success
	ret
