XLIB fatfs_file_addfpos

LIB fatfs_clus_nextsector

include	"../lowio/lowio.def"
include	"fatfs.def"

; ***************************************************************************
; * Subroutine to add offset to fileposition                                *
; ***************************************************************************
; TBD: May not work with offsets >64K-512. Does this matter?
; Entry: IY=filehandle, IX=partition handle, BC=bytes
; Exit: Fc=1 (success)
;   or: Fc=0 (failure) and A=error
; ABCDEHL corrupt.

.fatfs_file_addfpos
	ld	l,(iy+file_fatfs_filepos)
	ld	h,(iy+file_fatfs_filepos+1)
	add	hl,bc			; add to low word
	ld	(iy+file_fatfs_filepos),l
	ld	(iy+file_fatfs_filepos+1),h
	jr	nc,file_addfpos_offset	; on if no carry
	inc	(iy+file_fatfs_filepos+2)	; increment 3rd byte
	jr	nz,file_addfpos_offset	; on if no wrap
	inc	(iy+file_fatfs_filepos+3)	; increment high byte
.file_addfpos_offset
	bit	fm_valid,(iy+file_fatfs_mode)	; is location valid?
	scf				; success
	ret	z			; don't bother updating if not
	ld	l,(iy+file_fatfs_offset)
	ld	h,(iy+file_fatfs_offset+1)
	add	hl,bc			; add to offset
	ld	(iy+file_fatfs_offset),l
	ld	(iy+file_fatfs_offset+1),h
.file_addfpos_nextsector
	ld	bc,512
	and	a
	sbc	hl,bc
	ret	c			; okay if still < 512
	ld	(iy+file_fatfs_offset),l	; reduce offset by 512
	ld	(iy+file_fatfs_offset+1),h
	ld	c,(iy+file_fatfs_cluster)
	ld	b,(iy+file_fatfs_cluster+1)
	ld	a,(iy+file_fatfs_sector)	; BC,A=cluster,sector
	call	fatfs_clus_nextsector		; update to next
	jr	nc,file_addfpos_failed
	ld	(iy+file_fatfs_cluster),c	; store updated cluster,sector
	ld	(iy+file_fatfs_cluster+1),b
	ld	(iy+file_fatfs_sector),a
	ld	l,(iy+file_fatfs_offset)
	ld	h,(iy+file_fatfs_offset+1)
	jr	file_addfpos_nextsector	; go back to re-test offset
.file_addfpos_failed
	res	fm_valid,(iy+file_fatfs_mode)	; location no longer valid
	cp	rc_eof			; is error EOF?
	scf
	ccf				; ensure Fc=0
	ret	nz			; exit with real error if not
	scf				; success
	ret
