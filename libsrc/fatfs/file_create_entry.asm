XLIB file_create_entry

include "fatfs.def"

LIB dir_getfree
LIB buf_writebuf

; ***************************************************************************
; * Subroutine to create directory entry for new file                       *
; ***************************************************************************
; Entry: IY=directory handle, IX=partition handle
;	 dir_filespec1 contains 11-byte filename (must not exist in directory)
; Exit: Fc=1 (success), current entry is now filled in
;       Fc=0 (failure), A=error
; ABCDEHLIX corrupt

.file_create_entry
	call	dir_getfree		; HL=free directory entry
	ret	nc			; exit if error
	ex	de,hl
	ld	hl,dir_filespec1
	ld	bc,11
	ldir				; copy in name and extension
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
	jp	buf_writebuf		; write directory entry
