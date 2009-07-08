XLIB dir_getfirstmatch
XDEF dir_getcurrentmatch

include "fatfs.def"

LIB dir_home
LIB dir_matchname
LIB dir_next

; ***************************************************************************
; * Find next filename match                                                *
; ***************************************************************************
; On entry, IY=directory handle, IX=partition handle, DE=11-byte filespec
; Enter at dir_getfirstmatch to start with first entry in directory,
;       or dir_getcurrentmatch to start with current entry in directory,
;       or dir_getnextmatch to start with next entry
; to skip current entry.
; On exit, Fc=1 (success), Fz=1 if matched (now current entry), or Fz=0 if not
; or, Fc=0 (failure) and A=error
; ABCHL corrupted.

.dir_getfirstmatch
	call	dir_home
	ret	nc
.dir_getcurrentmatch
	push	de
	call	dir_matchname		; does current entry match?
	pop	de
	ret	z			; exit if match
	ret	nc			; or if error
.dir_getnextmatch
	push	de
	call	dir_next		; get next entry
	pop	de
	jr	c,dir_getcurrentmatch
	xor	a
	inc	a			; Fz=0, no match
	scf				; success
	ret
