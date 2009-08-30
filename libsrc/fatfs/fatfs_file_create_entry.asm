XLIB fatfs_file_create_entry

LIB fatfs_dir_getfree
LIB buffer_writebuf

include	"../lowio/lowio.def"

; ***************************************************************************
; * Subroutine to create directory entry for new file                       *
; ***************************************************************************
; Entry: IY=directory handle, IX=partition handle
;	 HL = pointer to null-terminated 8.3 filename (must not exist in directory)
; Exit: Fc=1 (success), current entry is now filled in
;       Fc=0 (failure), A=error
; ABCDEHLIX corrupt

.fatfs_file_create_entry
	push hl
	call	fatfs_dir_getfree		; HL=free directory entry
	ex	de,hl
	pop hl
	ret	nc			; exit if error

	; copy up to the first '.' or null -
	; for now, we'll assume that we're passed something that fits in 8 bytes
	ld bc,8
.copy_first_part
	ld a,(hl)
	or a
	jr z,first_part_ended
	cp '.'
	jr z,first_part_ended
	ldi
	jr copy_first_part
.first_part_ended
	; pad with spaces until c=0
	inc c
	ld a,' '
.pad_first_part
	dec c
	jr z,pad_first_part_done
	ld (de),a
	inc de
	jr pad_first_part
.pad_first_part_done

	; next character is either \0 or '.' - skip past the '.' if there was one
	ld a,(hl)
	or a
	jr z,no_dot
	inc hl
.no_dot
	ld bc,3
.copy_extension
	ld a,(hl)
	or a
	jr z,extension_ended
	ldi
	jr copy_extension
.extension_ended
	; pad with spaces until c = 0
	inc c
	ld a,' '
.pad_extension
	dec c
	jr z,pad_extension_done
	ld (de),a
	inc de
	jr pad_extension
.pad_extension_done
	
	ld	h,d
	ld	l,e

	xor	a
	ld	(hl),a			; zero attributes
	ld	c,10+2+2
	inc	de
	ldir				; zero unused, time and date
	ex	de,hl
	ld	(hl),$ff		; start cluster=$ffff
	inc	hl
	ld	(hl),$ff
	inc	hl
	ld	(hl),a			; zero filesize
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	jp	buffer_writebuf		; write directory entry
