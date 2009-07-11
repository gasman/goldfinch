XLIB fatfs_fat_readfat

include "fatfs.def"

LIB fatfs_buf_findbuf

; ***************************************************************************
; * Read FAT entry                                                          *
; ***************************************************************************
; On entry, IX=partition handle & BC=cluster number
; On exit, BC=contents of FAT entry, Fc=1 (success)
; Or, Fc=0, failure (A=error)
; ADEHL corrupted.

.fatfs_fat_readfat
	bit	7,(ix+fph_fattype)	; FAT12 or FAT16?
	jr	z,fat_readfat12
	ld	a,(ix+fph_fatsize+1)
	and	a
	jr	nz,fat_readfat16_inrange ; >255 sectors per FAT, so must be OK
	ld	a,b
	cp	(ix+fph_fatsize)
	ld	a,rc_seek
	ret	nc			; exit with seek error if FAT too small
.fat_readfat16_inrange	
	push	bc			; save cluster number
	ld	l,(ix+fph_fat1_start)
	ld	h,(ix+fph_fat1_start+1)
	ld	a,(ix+fph_fat1_start+2)	; AHL=start of FAT1
	ld	e,b
	ld	d,0			; DE=sector offset within FAT
	ld	b,(ix+fph_fat_copies)	; B=copies of FAT to try
.fat_readfat16_trynext	
	add	hl,de
	adc	a,0			; AHL=sector in FAT containing entry
	ex	de,hl
	ld	c,a
	ld	b,0			; BCDE=sector to read
	push	de			; save in case of read error
	push	bc
	call	fatfs_buf_findbuf		; get HL=address of sector in memory
	pop	bc
	pop	de			; restore sector number & copies
	jr	c,fat_readfat16_ok	; on if no error
	dec	b
	jr	z,fat_readfat16_error	; no copies left to try
	ex	de,hl
	ld	a,c			; AHL=sector number (current FAT)
	ld	e,(ix+fph_fatsize)
	ld	d,(ix+fph_fatsize+1)	; DE=offset to next FAT
	jr	fat_readfat16_trynext	; try another
.fat_readfat16_error
	pop	bc			; discard cluster number
	ret				; exit with Fc=0, A=error
.fat_readfat16_ok
	pop	bc			; restore cluster number
	ld	b,0
	add	hl,bc
	add	hl,bc			; HL=address of FAT entry
	ld	c,(hl)
	inc	hl
	ld	b,(hl)			; BC=contents of FAT entry
	scf				; success!
	ret
.fat_readfat12
	ld	a,rc_notimp		; FAT12 not yet implemented
	and	a
	ret
