XLIB fatfs_drive_init_callee
XDEF fatfs_drive_init_asmentry
XDEF ASMDISP_FATFS_DRIVE_INIT_CALLEE

include "fatfs.def"

LIB read_block_callee
XREF read_block_asmentry
LIB fatfs_dir_findvolumelabel

.fatfs_drive_init_callee
	pop hl
	pop de
	ex (sp),hl

; ***************************************************************************
; * Initialize partition handle from block device                           *
; ***************************************************************************
; (cobbled together from drive_getpartition in ResiDOS fatfs)
; enter with hl = pointer to block_device, de = pointer to partition handle to be filled in
; Exit: Fc=1 (success), IX=filled in, DE=name address, B=name length (8/11)
;       Fc=0 (failure), A=error
; AFBCDEHLIY corrupt
.fatfs_drive_init_asmentry
	push de	; save pointer to partition handle
	; copy the block device structure to the partition handle
	ld bc,blockdev_size
	ldir
	pop ix ; refetch pointer to partition handle
	
	ld	b,0
	ld	c,b
	ld	d,b
	ld	e,b
	ld	hl,(drive_sectorbuf)
	call	read_block_asmentry + (read_block_callee-read_block_callee)	; read the boot sector
	ret	nc			; exit with error
	ld	iy,(drive_sectorbuf)
	ld	(ix+fph_fattype),fattype_fat16
	ld	(ix+fph_maxclust),$ef	; max FAT16 cluster is $ffef
	ld	(ix+fph_maxclust+1),$ff
	ld	a,(iy+bootrec_secsize)	; must be 512bytes/sec
	and	a
	jp	nz,drive_gp_badfat
	ld	a,(iy+bootrec_secsize+1)
	cp	2
	jp	nz,drive_gp_badfat
	ld	a,(iy+bootrec_clussize)
	and	a
	jp	z,drive_gp_badfat
	ld	(ix+fph_clussize),a	; set cluster size
	ld	l,(iy+bootrec_resvd)
	ld	h,(iy+bootrec_resvd+1)
	ld	(ix+fph_fat1_start),l	; set FAT start
	ld	(ix+fph_fat1_start+1),h	; 0HL=FAT1 start
	ld	(ix+fph_fat1_start+2),0
	ld	a,(iy+bootrec_fatcopies)
	and	a
	jp	z,drive_gp_badfat
	ld	(ix+fph_fat_copies),a	; set # FATs
	ld	b,a			; B=# FATs
	ld	e,(iy+bootrec_fatsize)
	ld	d,(iy+bootrec_fatsize+1) ; DE=FATsize
	ld	a,d
	or	e
	jp	z,drive_gp_badfat
	ld	(ix+fph_fatsize),e
	ld	(ix+fph_fatsize+1),d
	xor	a			; AHL=FAT1 start
.drive_gp_fat16_calcrootstart
	add	hl,de
	adc	a,0			; next FAT start
	djnz	drive_gp_fat16_calcrootstart
	ld	(ix+fph_root_start),l	; set root start
	ld	(ix+fph_root_start+1),h
	ld	(ix+fph_root_start+2),a
	ld	e,(iy+bootrec_rootents)
	ld	d,(iy+bootrec_rootents+1)
	ld	a,e
	and	15
	jr	nz,drive_gp_badfat	; should be multiple of 16
	srl	d
	rr	e
	srl	d
	rr	e
	srl	d
	rr	e
	srl	d
	rr	e			; DE=root sectors
	ld	a,d
	or	e
	jp	z,drive_gp_badfat
	ld	(ix+fph_rootsize),e	; set root size
	ld	(ix+fph_rootsize+1),d
	add	hl,de
	ld	a,(ix+fph_root_start+2)
	adc	a,0			; AHL=data start
	ld	(ix+fph_data_start),l	; set data start
	ld	(ix+fph_data_start+1),h
	ld	(ix+fph_data_start+2),a
	ld	(ix+fph_lastalloc),$01	; initialise lastalloc
	ld	(ix+fph_lastalloc+1),$00
	ld	(ix+fph_freeclusts),$ff	; set free clusters=$ffff (not yet calculated)
	ld	(ix+fph_freeclusts+1),$ff
	ld	a,(iy+bootrec_extsig)
	cp	bootrec_extsig_byte
	ld	de,novolname		; use "NO NAME" as default if no ext sig
	jr	nz,drive_gp_noextsig
	ld	de,bootrec_volname	; else use boot record volume name
	add	iy,de
	push	iy			; stack address of volumename
	pop	hl
	ld	de,dir_filespec1
	ld	bc,11
	ldir				; copy to filespec1
	ld	de,dir_filespec1
.drive_gp_noextsig
	push	de
	call	fatfs_dir_findvolumelabel	; HL=volume label, if any
	pop	de			; DE=default volume name
	jr	nc,drive_gp_badfat	; exit with any error; not valid
	ld	b,11			; volume name is 11 chars
	scf				; success
	ret	z			; exit if didn't find volume label
	ex	de,hl			; else use found name
	ret
.drive_gp_badfat
	ld	a,rc_invpartition
	and	a			; Fc=0
	ret
	
.novolname
	defm	"NO NAME    "

DEFC ASMDISP_FATFS_DRIVE_INIT_CALLEE = fatfs_drive_init_asmentry - fatfs_drive_init_callee