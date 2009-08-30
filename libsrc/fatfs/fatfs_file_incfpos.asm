XLIB fatfs_file_incfpos

LIB fatfs_clus_nextsector

include	"../lowio/lowio.def"
include	"fatfs.def"

; ***************************************************************************
; * Subroutine to increment fileposition                                    *
; ***************************************************************************
; Entry: IY=filehandle, IX=partition handle
; Exit: Fc=1 (success)
;   or: Fc=0 (failure) and A=error
; ABCDEHL corrupt.

.fatfs_file_incfpos
	inc	(iy+file_fatfs_filepos)	; increment low byte
	jr	nz,file_incfpos_offset	; on if no wrap
	inc	(iy+file_fatfs_filepos+1)	; increment 2nd byte
	jr	nz,file_incfpos_offset	; on if no wrap
	inc	(iy+file_fatfs_filepos+2)	; increment 3rd byte
	jr	nz,file_incfpos_offset	; on if no wrap
	inc	(iy+file_fatfs_filepos+3)	; increment high byte
.file_incfpos_offset
	bit	fm_valid,(iy+file_fatfs_mode)	; is location valid?
	scf				; success
	ret	z			; don't bother updating if not
	inc	(iy+file_fatfs_offset)		; increment low byte of offset
	ret	nz			; done if no wrap
	inc	(iy+file_fatfs_offset+1)	; increment high byte of offset
	bit	1,(iy+file_fatfs_offset+1)
	ret	z			; okay if still < 512
	ld	(iy+file_fatfs_offset+1),0	; reset offset to zero
	ld	c,(iy+file_fatfs_cluster)
	ld	b,(iy+file_fatfs_cluster+1)
	ld	a,(iy+file_fatfs_sector)	; BC,A=cluster,sector
	call	fatfs_clus_nextsector		; update to next
	jr	c,file_incfpos_okay	; on if okay
	res	fm_valid,(iy+file_fatfs_mode)	; location no longer valid
	cp	rc_eof			; is error EOF?
	scf
	ccf				; ensure Fc=0
	ret	nz			; exit with real error if not
	scf				; success
	ret
.file_incfpos_okay
	ld	(iy+file_fatfs_cluster),c	; store updated cluster,sector
	ld	(iy+file_fatfs_cluster+1),b
	ld	(iy+file_fatfs_sector),a
	ret				; exit with Fc=1
