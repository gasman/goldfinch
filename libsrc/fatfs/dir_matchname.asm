XLIB dir_matchname

include "fatfs.def"

LIB dir_entrydetails

; ***************************************************************************
; * Check filename match                                                    *
; ***************************************************************************
; On entry, IY=directory handle, IX=partition handle, DE=11-byte filespec
; On exit, Fc=1 if successful, and Fz=1 if current entry matches
; or, Fc=0 and A=error
; ABCDEHL corrupted.

.dir_matchname
	push	de
	call	dir_entrydetails	; get HL=entry address
	pop	de
	ret	nc			; exit if error
	jr	z,dir_matchname_nomatch	; no match if free entry
	bit	dirattr_vol,a
	ret	nz			; no match if volume label
	ld	b,11			; 11 bytes to match
.dir_matchname_loop
	ld	a,(de)			; next match char
	inc	de
	cp	'?'			; wild char always matches
	jr	z,dir_matchname_matchchar
	cp	(hl)
	scf
	ret	nz			; exit if match fails
.dir_matchname_matchchar
	inc	hl
	djnz	dir_matchname_loop
	xor	a			; Fz=1, match
	scf				; success!
	ret
.dir_matchname_nomatch
	xor	a
	inc	a			; Fz=0, no match
	scf				; success
	ret
