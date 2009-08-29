XLIB fatfs_clus_erase

include "fatfs.def"

LIB fatfs_clus_tobuf_noread
LIB fatfs_clus_getsector
LIB write_block_asm

; ***************************************************************************
; * Erase cluster                                                           *
; ***************************************************************************
; On entry, IX=partition handle, BC=cluster
; On exit, Fc=1 (success), with HL=buffer address of first sector
; Or, Fc=1 (fail) and A=error
; ABCDE corrupted.
	
.fatfs_clus_erase
	push	bc
	xor	a
	call	fatfs_clus_tobuf_noread	; get a buffer for the first cluster sector
	pop	bc
	ret	nc			; exit if error
	push	hl			; save buffer address
	push	bc			; and cluster
	ld	d,h
	ld	e,l
	inc	de
	ld	bc,buf_secsize-1
	ld	(hl),0
	ldir				; erase the buffer
	pop	bc
	xor	a			; BC,A=cluster,start sector
	call	fatfs_clus_getsector		; BCDE=logical sector
	pop	hl
	ret	nc			; exit if error
	ld	a,(ix+fph_clussize)	; A=sectors per cluster
.clus_erase_loop
	push	af
	push	bc
	push	de
	push	hl
	call write_block_asm
	
	pop	hl
	pop	de
	pop	bc
	jr	nc,baderase		; exit if error
	inc	de			; increment sector low word
	ld	a,d
	or	e
	jr	nz,clus_erase_sectorok
	inc	bc			; increment sector high word
.clus_erase_sectorok
	pop	af
	dec	a
	jr	nz,clus_erase_loop	; back to erase remaining sectors
	scf				; success!
	ret				; exit with HL=buffer address
.baderase
	pop	de			; discard remaining sectors
	ret
