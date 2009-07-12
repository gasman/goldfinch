XLIB fatfs_dir_entrydetails_callee
XDEF fatfs_dir_entrydetails_asmentry

include "fatfs.def"

LIB fatfs_dir_getentry

; extern FATFS_DIR_ENTRY __LIB__ __CALLEE__ *fatfs_dir_entrydetails_callee(FATFS_DIRECTORY *dir, FATFS_FILESYSTEM *fs)
.fatfs_dir_entrydetails_callee
	pop hl	; return address
	pop ix	; partition handle
	pop iy	; directory handle
	push hl

; ***************************************************************************
; * Examine current entry                                                   *
; ***************************************************************************
; On entry, IY=directory handle, IX=partition handle
; On exit, Fc=1 (success), HL=entry address,
;  Fz=1 if unused entry, otherwise A=attributes byte
; or, Fc=0 (failure) and A=error
; ABCDEHL corrupted.

.fatfs_dir_entrydetails_asmentry
	call	fatfs_dir_getentry		; locate entry
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
