XLIB fatfs_fat_writefat

include "fatfs.def"

LIB fatfs_fat_readfat
LIB write_block_asm

; ***************************************************************************
; * Write FAT entry                                                         *
; ***************************************************************************
; On entry, IX=partition handle, BC=cluster number, DE=data to write
; On exit, Fc=1 for success
; or Fc=0, A=error
; ABCDEHL corrupted.

.fatfs_fat_writefat
	push	de			; save data to write
	push	bc			; save cluster number
	call	fatfs_fat_readfat		; read the FAT entry
	pop	bc
	pop	de
	ret	nc			; exit with any error

	; At this point, the MRU buffer contains the FAT sector to modify
	; (For FAT12, this may be the 2nd of 2 sectors, in which case
	;  the first will be in the next MRU buffer).
	; For FAT16, HL=high byte of data to modify
	; For FAT12, ??

	bit	7,(ix+fph_fattype)	; FAT12 or FAT16?
	jr	z,fat_writefat12
	ld	(hl),d			; modify entry
	dec	hl
	ld	(hl),e
	ld	d,0
	ld	e,b			; DE=sector offset within FAT
	ld	b,d
	and	a
	sbc	hl,bc
	sbc	hl,bc			; HL=sector buffer start
	push	hl			; save buffer address
	ld	l,(ix+fph_fat1_start)
	ld	h,(ix+fph_fat1_start+1)
	ld	a,(ix+fph_fat1_start+2)	; AHL=start of FAT1
	ld	b,(ix+fph_fat_copies)	; B=copies of FAT to write
.fat_writefat16_donext	
	add	hl,de
	adc	a,0			; AHL=sector in FAT containing entry
	ex	de,hl
	pop	hl			; HL=buffer address
	push	hl			; resave
	ld	c,a
	push	bc			; save B=copies to write, C=sector high
	ld	b,0			; BCDE=sector to write
	push	de			; save sector low
	
	call write_block_asm
	
	; TBD: remove any copies held in buffers? Should be okay, as we should
	;      never have more than the 1st readable copy.
	
	pop	hl			; sector low
	pop	bc			; sector high, copies
	dec	b
	jr	z,fat_writefat16_end	; finished all copies
	ld	a,c			; AHL=sector number (current FAT)
	ld	e,(ix+fph_fatsize)
	ld	d,(ix+fph_fatsize+1)	; DE=offset to next FAT
	jr	fat_writefat16_donext	; back for remaining FAT copies
.fat_writefat16_end
	pop	hl			; discard buffer address
	ret				; exit with success/error
					; TBD: Should succeed if *any* copy written OK
.fat_writefat12
	ld	a,rc_notimp		; FAT12 not yet implemented
	and	a
	ret
