XLIB fatfs_dir_entrydetails_lowio

include "fatfs.def"

LIB fatfs_dir_getentry_lowio

; ***************************************************************************
; * Examine current entry                                                   *
; ***************************************************************************
; On entry, IY=directory handle (lowio.def), IX=partition handle
; On exit, Fc=1 (success), HL=entry address,
;  Fz=1 if unused entry, otherwise A=attributes byte
; or, Fc=0 (failure) and A=error
; ABCDEHL corrupted.

.fatfs_dir_entrydetails_lowio
	call	fatfs_dir_getentry_lowio		; locate entry
	ret	nc			; exit if error
	ld	a,(hl)
	and	a			; free entry if zero
	scf
	ret	z			; exit with Fc=1, Fz=1 if unused
	cp	direntry_deleted
	scf
	ret	z			; or if deleted
	push	hl
	ld	bc,direntry_attr
	add	hl,bc
	ld	a,(hl)			; A=attributes byte
	pop	hl			; restore HL=entry address
	scf				; success!
	ret
