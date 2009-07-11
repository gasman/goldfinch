XLIB fatfs_buf_writebuf
XDEF fatfs_buf_writeany

include "fatfs.def"

LIB fatfs_buf_gethandle
LIB fatfs_buf_setmru
XREF fatfs_buf_getaddress

; ***************************************************************************
; * Subroutine to write the MRU buffer                                      *
; ***************************************************************************
; On exit, Fc=1 (success) or Fc=0 and A=error.
; ABCDEHLIX corrupted.
; IX is changed to the partition handle of the MRU buffer.
; Enter at buf_writeany to write a specific buffer (A) without setting as MRU

.fatfs_buf_writebuf
	ld	a,(buf_mrulist)
.fatfs_buf_writeany
	push	iy
	push	af
	call	fatfs_buf_gethandle		; get buffer handle
	ld	a,(iy+fbh_phandle)	; get partition handle to IX
	ld	ixl,a
	ld	a,(iy+fbh_phandle+1)
	ld	ixh,a
	pop	af
	call	fatfs_buf_getaddress		; get address in HL
	res	bufflag_upd,(iy+fbh_flags)	; clear update flag
	ld	e,(iy+fbh_sector)	; get sector to BCDE
	ld	d,(iy+fbh_sector+1)
	ld	c,(iy+fbh_sector+2)
	ld	b,(iy+fbh_sector+3)
	pop	iy
	
	; jp	PACKAGE_FS_SECTOR_WRITE	; write sector and exit with error status
	; FIXME: writing to block device not yet implemented. Temporary do-nothing code:
	or a	; reset carry flag
	ret
