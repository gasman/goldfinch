; void __CALLEE__ fatfs_fsopen_callee(BLOCK_DEVICE *device, FILESYSTEM *fs)
; open a block device for access as a FAT file system

XLIB fatfs_fsopen_callee
XDEF fatfs_fsopen_asmentry

LIB fatfs_phandle_allocate
LIB read_block_asm
LIB fatfs_open_root_dir
LIB fatfs_read_dir
LIB fatfs_open_dirent
LIB fatfs_read_file
LIB drive_sectorbuf
LIB fatfs_file_close
LIB fatfs_open_subdir
LIB fatfs_dir_home
LIB fatfs_file_write
LIB fatfs_create_file
LIB fatfs_seek_file
LIB fatfs_read_byte
LIB fatfs_file_getfilepos

include	"../lowio/lowio.def"
include	"fatfs.def"

.fatfs_fsopen_callee
	pop hl
	pop ix
	ex (sp),hl

   ; enter : hl = BLOCK_DEVICE *device
   ;         ix = FILESYSTEM *fs
   ; uses  : hl, de, ix
   
.fatfs_fsopen_asmentry
	; set pointer to the fatfs filesystem driver
	ld de,fatfs_filesystem_driver
	ld (ix+filesystem_driver),e
	ld (ix+filesystem_driver+1),d
	; allocate space for a FAT partition handle struct
	push ix	; store filesystem struct pointer
	push hl	; store block device pointer

	call fatfs_phandle_allocate ; get a free partition handle into hl

	pop de	; recall block device pointer
	pop ix	; recall filesystem struct pointer
	ret nc                      ; mem alloc failed, hl = 0

	; fill in the filesystem struct with a pointer to the newly allocated block
	ld (ix+filesystem_data),l
	ld (ix+filesystem_data+1),h
	
	push hl	; save partition handle pointer
	; copy block device object to start of partition handle
	ex de,hl
	ld bc,blockdev_size
	ldir
	
	pop ix	; get FAT partition handle into IX
	; now populate the remaining fields of the partition handle
	ld	b,0
	ld	c,b
	ld	d,b
	ld	e,b
	ld	hl,(drive_sectorbuf)
	call	read_block_asm	; read the boot sector.
		; FIXME: why do we need to pre-allocate a buffer? Why not just call buffer_readbuf?
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
	scf				; success
	ret
.drive_gp_badfat
	ld	a,rc_invpartition
	and	a			; Fc=0
	ret
	
.fatfs_filesystem_driver
	; jump table to fs routines
	jp fatfs_open_root_dir
	jp fatfs_read_dir
	jp fatfs_open_dirent
	jp fatfs_read_file
	jp fatfs_file_close
	jp fatfs_open_subdir
	jp fatfs_dir_home
	jp fatfs_file_write
	jp fatfs_create_file
	jp fatfs_seek_file
	jp fatfs_read_byte
	jp fatfs_file_getfilepos