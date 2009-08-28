XLIB fatfs_file_getvalidaddr

include	"fatfs.def"
include	"../lowio/lowio.def"

LIB fatfs_clus_valid
LIB fatfs_clus_allocate
LIB fatfs_file_getfilepos
LIB fatfs_fat_readfat
LIB fatfs_clus_extendchain
LIB fatfs_clus_readtobuf

; ***************************************************************************
; * Subroutine to get valid address for current filepos                     *
; ***************************************************************************
; Entry: IY=filehandle, IX=partition handle (both lowio.def)
; Exit: Fc=1 (success), HL=address, DE=offset (ie HL-DE=start of sector buffer)
;   or: Fc=0 (failure) and A=error
; ABCDE corrupt.

.fatfs_file_getvalidaddr
	bit	fm_valid,(iy+file_fatfs_mode)	; is location valid?
	jr	nz,file_getvalidaddr_valid	; almost done, then

	; Now we have to go through from the beginning, until get to right position
	
	ld	c,(iy+file_fatfs_clusstart)
	ld	b,(iy+file_fatfs_clusstart+1)
	call	fatfs_clus_valid		; is this a valid cluster?
	jr	c,file_getvalidaddr_startok
	call	fatfs_clus_allocate		; allocate a new cluster
	ret	nc			; exit if error
	ld	(iy+file_fatfs_clusstart),c	; store in file handle
	ld	(iy+file_fatfs_clusstart+1),b
	set	fm_entry,(iy+file_fatfs_mode)	; directory entry needs updating
.file_getvalidaddr_startok
	push	bc			; TOS=initial cluster
	call	fatfs_file_getfilepos		; DEHL=fileposition required
	ld	a,(ix+fph_clussize)	; A=cluster size in sectors
	add	a,a
	ld	b,a
	ld	c,0			; BC=cluster size in bytes	
.file_getvalidaddr_clusterloop
	and	a
	sbc	hl,bc			; subtract cluster size from filepos
	jr	nc,file_getvalidaddr_nextcluster
	ld	a,d
	or	e			; if high word zero, within cluster
	jr	z,file_getvalidaddr_thiscluster
	dec	de			; decrement high word
.file_getvalidaddr_nextcluster
	ex	(sp),hl			; save HL, HL=cluster
	push	de			; save registers
	push	bc
	ld	b,h
	ld	c,l
	push	bc			; save source cluster
	call	fatfs_fat_readfat		; BC=next cluster
	jr	nc,file_getvalidaddr_badcluster
	call	fatfs_clus_valid		; is this a valid cluster?
	jr	nc,file_getvalidaddr_extend	; extend file if not
	pop	hl			; discard source cluster
.file_getvalidaddr_extended
	ld	h,b
	ld	l,c
	pop	bc			; restore registers
	pop	de
	ex	(sp),hl
	jr	file_getvalidaddr_clusterloop	; loop back
.file_getvalidaddr_extend
	pop	bc			; get previous cluster again
	call	fatfs_clus_extendchain	; extend the chain
	jr	file_getvalidaddr_extended
.file_getvalidaddr_badcluster
	pop	bc			; discard registers
	pop	bc
	pop	bc
	pop	bc
	ret				; exit with error
.file_getvalidaddr_thiscluster
	add	hl,bc			; HL=offset within cluster
	pop	bc
	ld	(iy+file_fatfs_cluster),c	; store cluster
	ld	(iy+file_fatfs_cluster+1),b
	ld	bc,buf_secsize
	xor	a			; A=sector offset, Fc=0
.file_getvalidaddr_sectorloop
	sbc	hl,bc
	inc	a
	jr	nc,file_getvalidaddr_sectorloop
	add	hl,bc			; HL=offset within sector
	dec	a			; A=sector offset
	ld	(iy+file_fatfs_sector),a	; store sector
	ld	(iy+file_fatfs_offset),l	; store offset
	ld	(iy+file_fatfs_offset+1),h
	set	fm_valid,(iy+file_fatfs_mode)	; now valid!
.file_getvalidaddr_valid
	ld	c,(iy+file_fatfs_cluster)
	ld	b,(iy+file_fatfs_cluster+1)
	ld	a,(iy+file_fatfs_sector)
	call	fatfs_clus_readtobuf		; get to buffer
	ret	nc			; exit if error
	ld	e,(iy+file_fatfs_offset)
	ld	d,(iy+file_fatfs_offset+1)
	add	hl,de			; HL=address of byte
	scf				; success!
	ret
