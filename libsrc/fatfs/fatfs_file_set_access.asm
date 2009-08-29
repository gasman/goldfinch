XLIB fatfs_file_set_access
XDEF fatfs_file_validate_access

LIB fatfs_file_commit
LIB fatfs_dir_entrydetails
; LIB fatfs_file_isopen_lowio

include	"../lowio/lowio.def"
include	"fatfs.def"

; ***************************************************************************
; * FAT_SET_ACCESS                                                          *
; ***************************************************************************
; Entry: IY=filehandle, IX=fatfs partition handle (lowio.def)
;	 C=access mode: bit 0=read, bit 1=write, bit 2=shared
;                       (shared only allowed with read)
; Or enter at file_validate access with: IY=filehandle (filled in except mode)
;					 C=access mode, B=0
; Exit: Fc=1 (success)
;       Fc=0 (failure), A=error
; ABCDEHLIXIY corrupt

.fatfs_file_set_access
	ld	b,(iy+file_fatfs_mode)
	push	bc			; save access mode and new
	call	fatfs_file_commit		; update header & dir, commit changes
	pop	bc
	ret	nc			; exit if error
	ld	(iy+file_fatfs_mode),0		; temporarily close file
.fatfs_file_validate_access
	push	bc			; save current (B) and new (C) modes

	; call	fatfs_file_isopen_lowio		; check if other handle open to it
	scf	; TEMP - treat file as not open
	; TODO: reimplement file handles so that they're allocated by fatfs, so that
	; fatfs can iterate over them
	
	pop	bc			; restore access mode and new
	ld	(iy+file_fatfs_mode),b		; change mode back
	jr	c,file_set_unshared	; okay if not open to other handle
	bit	fm_shared,c		; if open, must stay shared
	jr	z,file_set_bad
	cp	fm_shared_read		; and other file must be shared read
	jr	nz,file_set_bad
.file_set_unshared
	ld	a,c			; check desired mode
	cp	fm_exc_read		; read is always okay
	jr	z,file_set_okay
	cp	fm_shared_read		; read is always okay
	jr	z,file_set_okay
	cp	fm_exc_write		; write needs checking
	jr	z,file_set_write
	cp	fm_exc_rw		; write needs checking
	jr	nz,file_set_bad		; any other combination is bogus
.file_set_write
	push	bc
	call	fatfs_dir_entrydetails	; get A=attributes
	pop	bc
	ret	nc			; exit if error
	bit	dirattr_ro,a		; is it read-only?
	jr	nz,file_set_bad		; error if so
.file_set_okay
	ld	a,b
	and	$ff-fm_access_mask	; get other existing mode bits
	or	c			; combine with new access mode
	ld	(iy+file_fatfs_mode),a
	scf				; success!
	ret
.file_set_bad
	ld	a,rc_denied
	and	a			; Fc=0
	ret
