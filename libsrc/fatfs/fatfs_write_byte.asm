XLIB fatfs_write_byte

LIB fatfs_file_maximisefilesize
LIB fatfs_file_getvalidaddr
LIB buffer_update
LIB fatfs_file_incfpos

include	"fatfs.def"
include	"../lowio/lowio.def"

; ***************************************************************************
; * FAT_BYTE_WRITE                                                          *
; ***************************************************************************
; Entry: IY=file handle, C=byte
; Exit: Fc=1 (success)
;       Fc=0 (failure), A=error
; ABCDEHLIX corrupt, IY preserved

.fatfs_write_byte
	; get partition handle (fph) into IX;
	; this is pointed to by filesystem_data,
	; which is embedded in the file handle
	ld l,(iy+file_filesystem+filesystem_data)
	ld h,(iy+file_filesystem+filesystem_data+1)
	push hl
	pop ix

	bit	fm_write,(iy+file_fatfs_mode)	; is access mode okay?
	jr	z,file_error_access
	push	bc
	call	fatfs_file_maximisefilesize	; ensure filesize updated if necessary
	call	fatfs_file_getvalidaddr	; get HL=address in buffer
	pop	bc
	jr	nc,file_error		; exit if error
	ld	(hl),c			; store byte
	call	buffer_update		; mark buffer as updated
	call	fatfs_file_incfpos		; add 1 to filepos and cluster etc
	scf				; success!
	ret

.file_error_access
	ld	a,rc_number
.file_error
	and	a			; Fc=0, error
	ret
