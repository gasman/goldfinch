XLIB fatfs_file_write

LIB tmp_rwaddr
LIB tmp_rwsize
LIB fatfs_file_getvalidaddr
LIB buffer_update
LIB fatfs_file_addfpos
LIB fatfs_file_maximisefilesize
LIB fatfs_file_incfpos

include "fatfs.def"
include	"../lowio/lowio.def"

; ***************************************************************************
; * FAT_WRITE                                                               *
; ***************************************************************************
; Entry: IY = file, HL=address, DE=size (0==64K)
; Exit: Fc=1 (success)
;       Fc=0 (failure), A=error, DE=bytes remaining unread
; Soft-EOF ($1a) is not considered.
; Attempting to read over the ROM area is an error. TBD: Should we trap this?
; ABCDEHLIXIY corrupt

.fatfs_file_write
	; get partition handle into ix
	push hl
	ld l,(iy + filesystem_fatfs_phandle)
	ld h,(iy + filesystem_fatfs_phandle + 1)
	push hl
	pop ix
	pop hl
	
	ld	(tmp_rwaddr),hl		; save address
	ld	(tmp_rwsize),de		; save size
	bit	fm_write,(iy+file_fatfs_mode)	; is access mode okay?
	jr	z,file_read_access
.file_write_writemax	
	call	fatfs_file_getvalidaddr	; get HL=address, DE=512-bytes
	jr	nc,file_read_error	; exit if error
	push	hl
	ld	hl,512
	and	a
	sbc	hl,de			; HL=bytes in sector
	pop	de			; DE=buffer address
	ld	bc,(tmp_rwsize)		; BC=bytes writable: May be zero==64K
	ld	a,b
	or	c
	jr	z,file_write_writeallbuf
	sbc	hl,bc
	jr	nc,file_write_writable	; buffer contains all rest of file
	add	hl,bc
.file_write_writeallbuf
	ld	b,h
	ld	c,l			; BC=bytes to write to this buffer
.file_write_writable
	push	bc
	ld	hl,(tmp_rwaddr)
	ldir				; copy bytes to buffer
	ld	(tmp_rwaddr),hl		; update address
	call	buffer_update
	pop	bc
	ld	hl,(tmp_rwsize)
	and	a
	sbc	hl,bc
	ld	(tmp_rwsize),hl		; update size left to write
	push	af			; save flag
	dec	bc
	call	fatfs_file_addfpos		; update filepointer to last written byte
	call	fatfs_file_maximisefilesize	; ensure filesize updated if necessary
	call	fatfs_file_incfpos		; update filepointer to next byte
	pop	af			; restore finished flag
	jr	z,file_read_done	; finished if size=0
	jr	file_write_writemax	; back for next sector

.file_read_done
	scf				; success!
	ret
.file_read_access
	ld	a,rc_number		; access mode error
.file_read_error
	ld	de,(tmp_rwsize)		; get bytes remaining
	and	a			; Fc=0, failure
	ret
