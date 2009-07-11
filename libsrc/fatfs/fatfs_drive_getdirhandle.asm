XLIB fatfs_drive_getdirhandle

include "fatfs.def"

LIB fatfs_drive_refdir

; ***************************************************************************
; * Subroutine to get directory and partition handles for drive             *
; ***************************************************************************
; Entry: A=drive, 'A'-'P'
; Exit: Fc=1 (success), IY=directory handle, IX=partition handle
;       Fc=0 (failure), A=error
; DEHL corrupt

.fatfs_drive_getdirhandle
	call	fatfs_drive_refdir		; DE=directory handle if Fz=0
	ret	nc			; exit if error
	ld	a,rc_nodrive
	ccf
	ret	z
	push	de
	pop	iy			; IY=directory handle
	ld	e,(iy+fdh_phandle)
	ld	d,(iy+fdh_phandle+1)
	push	de
	pop	ix			; IX=partition handle
	scf				; success!
	ret
