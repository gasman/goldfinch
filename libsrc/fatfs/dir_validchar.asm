XLIB dir_validchar

include "fatfs.def"

; ***************************************************************************
; * Validate character                                                      *
; ***************************************************************************
; On entry, A=character
; On exit, Fc=1 (valid), A=character (possibly modified)
; If invalid, Fc=0, A=rc_badname
; Nothing corrupted.

.dir_validchar
	cp	'a'
	jr	c,dir_validchar_notlower
	cp	'z'+1
	jr	nc,dir_validchar_notlower
	and	$df			; make uppercase
	scf				; now valid
	ret
.dir_validchar_notlower
	cp	'A'
	jr	c,dir_validchar_notupper
	cp	'Z'+1
	ret	c			; valid if uppercase
.dir_validchar_notupper
	cp	'0'
	jr	c,dir_validchar_notdigit
	cp	'9'+1
	ret	c			; valid if digit
.dir_validchar_notdigit
	push	hl
	push	bc
	ld	hl,miscvalidchars	; table of other valid characters
	ld	b,miscvalidchars_end-miscvalidchars
.dir_validchar_miscloop
	cp	(hl)
	scf				; valid
	jr	z,dir_validchar_ismisc	; okay if matches a misc character
	inc	hl
	djnz	dir_validchar_miscloop
	ld	a,rc_badname		; bad filename
	and	a			; Fc=0
.dir_validchar_ismisc
	pop	bc
	pop	hl
	ret

; TBD: These need checking.
.miscvalidchars
	defm	" !#$%^&'()-@_[]{}~"
.miscvalidchars_end
