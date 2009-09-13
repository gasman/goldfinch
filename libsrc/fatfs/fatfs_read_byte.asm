XLIB fatfs_read_byte

LIB fatfs_file_checkfilepos
LIB fatfs_file_getvalidaddr
LIB fatfs_file_incfpos

include	"fatfs.def"
include	"../lowio/lowio.def"

; ***************************************************************************
; * FAT_BYTE_READ                                                           *
; ***************************************************************************
; Entry: IY = file handle
; Exit: Fc=1 (success), L=byte, Fz=1 if L=$1a
;       Fc=0 (failure), A=error
; ABDEHLIXIY corrupt

.fatfs_read_byte
	; following code expects partition handle (fph) in ix;
	; this is pointed to by filesystem_data,
	; which is embedded in the file handle
	ld l,(iy+file_filesystem+filesystem_data)
	ld h,(iy+file_filesystem+filesystem_data+1)
	push hl
	pop ix

	bit	fm_read,(iy+file_fatfs_mode)	; is access mode okay?
	jr	z,file_error_access
	call	fatfs_file_checkfilepos	; Fc=1 if size > filepos (okay)
	jr	nc,file_error_eof
	call	fatfs_file_getvalidaddr	; get HL=address in buffer
	jr	nc,file_error		; exit if error
	ld	c,(hl)			; C=byte
	push	bc			; save
	call	fatfs_file_incfpos		; add 1 to filepos and cluster etc
	pop	hl
	ld h,0	; to ensure that result is still valid if it somehow gets
		; interpreted as an int
	ld	a,l
	cp	$1a			; check for soft-EOF
	scf				; success!
	ret

.file_error_access
	ld	a,rc_number
	jr	file_error
.file_error_eof
	ld	a,rc_eof
.file_error
	and	a			; Fc=0, error
	ret
