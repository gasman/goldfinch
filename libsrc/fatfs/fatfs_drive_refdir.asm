XLIB fatfs_drive_refdir

include "fatfs.def"

; ***************************************************************************
; * Subroutine to get directory handle pointer for drive                    *
; ***************************************************************************
; Entry: A=drive, 'A'-'P'
; Exit: Fc=1 (success), HL=address of pointer, DE=pointer, Fz=1 if DE=0
;       Fc=0 (failure), A=error

.fatfs_drive_refdir
	sub	'A'
	jr	c,drive_refdir_bad
	cp	drive_numdrives
	jr	nc,drive_refdir_bad
	ld	l,a
	ld	h,0
	add	hl,hl
	ld	de,drive_ptrs+1
	add	hl,de			; HL=address of pointer+1
	ld	d,(hl)
	dec	hl
	ld	e,(hl)			; HL=address of pointer, DE=pointer
	ld	a,d
	or	e			; Fz=1 if DE=0
	scf				; success
	ret
.drive_refdir_bad
	and	a
	ld	a,rc_badparam		; bad parameter error
	ret
