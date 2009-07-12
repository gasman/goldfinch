XLIB fatfs_dir_parsefilename

include "fatfs.def"

LIB fatfs_dir_validchar
LIB fatfs_drive_getdircopy
LIB fatfs_dir_root_callee
XREF fatfs_dir_root_asmentry
LIB fatfs_dir_getfirstmatch
LIB fatfs_dir_change

; ***************************************************************************
; * Parse filename                                                          *
; ***************************************************************************
; On entry, DE=address of filename/wildcard, $ff-terminated,
;           HL=address to place parsed 11-byte filespec
; On exit, Fc=1 (success), Fz=0 if wildcards used, Fs=1 if filename present
;          A=drive letter (or default)
;          IY=directory handle, IX=partition handle
; or Fc=0 and A=error (bad filename).
; ABCDE corrupted.

; Drive is held internally in C. This is an upper-case letter A-P, for
; which bit 7=0, bit 6=1, bit 5=0 always. Therefore we use bit 7 to
; indicate whether there was a filename segment (after the path)
; and bit 6 to indicate whether wildcards were present.
; Bit 7 is in the same location as the S (sign) flag.
; Bit 6 is in the same location as the Z (zero) flag.

.fatfs_dir_parsefilename
	ld	a,(fat_defdrive)	; default drive, no wildcards
	ld	c,a			; C=drive
	push	de			; save start address
	ld	a,(de)			; get first char
	inc	de
	cp	'1'			; user area 1 or 10-15?
	jr	nz,dir_parsefilename_lowuser
	ld	a,(de)			; get 2nd user area character
	inc	de
.dir_parsefilename_lowuser
	cp	'0'
	jr	c,dir_parsefilename_nodrive
	cp	'9'+1
	jr	nc,dir_parsefilename_trydrive
	ld	a,(de)
	inc	de
.dir_parsefilename_trydrive
	call	fatfs_dir_validchar		; drive letter now uppercase
	jr	nc,dir_parsefilename_nodrive
	cp	'A'
	jr	c,dir_parsefilename_nodrive
	cp	'P'+1
	jr	nc,dir_parsefilename_nodrive
	ld	b,a			; save drive from spec
	ld	a,(de)
	inc	de
	cp	':'			; should be : if drive/user
	jr	nz,dir_parsefilename_nodrive
	ld	c,b			; set drive
	pop	af			; discard saved address
	jr	dir_parsefilename_gooddrive
.dir_parsefilename_nodrive
	pop	de			; restore start address
.dir_parsefilename_gooddrive
	push	bc
	push	de
	push	hl
	ld	a,c
	call	fatfs_drive_getdircopy	; IY=copy of dirhandle, IX=parthandle
	pop	hl
	pop	de
	pop	bc
	ret	nc			; exit if error getting handles
	ld	a,(de)
	cp	'/'			; is root directory wanted?
	jr	z,dir_parsefilename_root
	cp	'\'
	jr	nz,dir_parsefilename_segment
.dir_parsefilename_root
	inc	de			; skip '\' or '/'
	call	fatfs_dir_root_asmentry + (fatfs_dir_root_callee-fatfs_dir_root_callee)	; change to root
.dir_parsefilename_segment
	res	7,c			; no filename part
	push	hl			; save start of destination
	ld	b,11
.dir_parsefilename_blankspec
	ld	(hl),' '		; erase the filespec
	inc	hl
	djnz	dir_parsefilename_blankspec
	pop	hl			; re-fetch & save destination
	push	hl
	ld	a,(de)
	cp	' '			; check first character not blank
	jr	z,dir_parsefilename_badname
	cp	'.'			; check for . or .. directories
	jr	z,dir_parsefilename_dots
	ld	b,8
.dir_parsefilename_name
	ld	a,(de)
	cp	$ff
	jr	z,dir_parsefilename_skiptoext
	set	7,c			; filename is present
	cp	'.'
	jr	z,dir_parsefilename_skiptoext
	inc	de
	cp	'*'
	jp	z,dir_parsefilename_wildname
	cp	'?'
	jp	z,dir_parsefilename_wildnamechar
	cp	'/'
	jr	z,dir_parsefilename_nextsegment
	cp	'\'
	jr	z,dir_parsefilename_nextsegment
	call	fatfs_dir_validchar		; make uppercase, check valid
	jr	nc,dir_pfn_exit		; exit if not valid
.dir_parsefilename_storename
	ld	(hl),a			; place in buffer
	inc	hl
	djnz	dir_parsefilename_name
.dir_parsefilename_doext
	ld	b,3			; characters in extension part
	ld	a,(de)
	inc	de
	cp	$ff			; no extension
	jr	z,dir_parsefilename_end
	cp	'.'			; an extension must be present
	jr	nz,dir_parsefilename_badname
.dir_parsefilename_ext
	ld	a,(de)			; get next part of extension
	inc	de
	cp	'*'			; skip rest of ext for '*'
	jr	z,dir_parsefilename_wildext
	cp	'?'			; skip this char for '?'
	jp	z,dir_parsefilename_wildextchar
	cp	'/'
	jr	z,dir_parsefilename_nextsegment
	cp	'\'
	jr	z,dir_parsefilename_nextsegment
	cp	$ff			; rest of ext must be blank
	jr	z,dir_parsefilename_end
	call	fatfs_dir_validchar		; make uppercase, check valid
	jr	nc,dir_pfn_exit		; exit if not valid
.dir_parsefilename_storeext
	ld	(hl),a			; place in buffer
	inc	hl
	djnz	dir_parsefilename_ext
	ld	a,(de)
	cp	$ff			; last character must be terminator
	jp	nz,dir_parsefilename_badname
.dir_parsefilename_end
	ld	b,c			; B=drive, with bits 7/6 corrupted
	res	7,b			; reset bit 7
	set	6,b			; and set bit 6
	set	0,c			; ensure bit 0 (Fc) is set
	push	bc
	pop	af			; A=drive, Fc=1, Fz=wildcard flag, Fs=filename flag
.dir_pfn_exit
	pop	hl			; discard destination start
	ret
.dir_parsefilename_badname
	pop	hl			; restore destination
	ld	a,rc_badname		; exit with bad filename error
	and	a
	ret
	
.dir_parsefilename_skiptoext
	ld	(hl),' '
	inc	hl
	djnz	dir_parsefilename_skiptoext
	jr	dir_parsefilename_doext

.dir_parsefilename_dots
	set	7,c			; filename is present
	ld	(hl),a			; transfer 1st dot
	inc	de
	inc	hl
	ld	a,(de)
	cp	'.'			; is 2nd char also a dot?
	jr	nz,dir_parsefilename_dotone
	ld	(hl),a			; transfer 2nd dot
	inc	de
.dir_parsefilename_dotone
	ld	a,(de)
	inc	de
	cp	'/'			; must be end of segment or filename
	jr	z,dir_parsefilename_nextsegment
	cp	'\'
	jr	z,dir_parsefilename_nextsegment
	cp	$ff
	jr	z,dir_parsefilename_end
	jp	dir_parsefilename_badname

.dir_parsefilename_nextsegment
	bit	6,c			; no wildcards in paths, please
	jp	z,dir_parsefilename_badname
	pop	hl			; HL=spec for current segment
	push	bc
	push	de
	push	hl
	ex	de,hl
	call	fatfs_dir_getfirstmatch	; find the directory
	jr	nc,dir_parsefilename_nextsegment_error
	ccf
	ld	a,rc_notdir
	call	z,fatfs_dir_change		; if successful, change to it
.dir_parsefilename_nextsegment_error
	pop	hl
	pop	de
	pop	bc
	ret	nc			; exit if error
	jp	dir_parsefilename_segment

.dir_parsefilename_wildname
	ld	(hl),'?'		; fill with ?
	inc	hl
	djnz	dir_parsefilename_wildname
	res	6,c			; wildcards present
	jp	dir_parsefilename_doext
.dir_parsefilename_wildnamechar
	res	6,c			; wildcards present
	jp	dir_parsefilename_storename
.dir_parsefilename_wildext
	ld	(hl),'?'		; fill with ?
	inc	hl
	djnz	dir_parsefilename_wildext
	res	6,c			; wildcards present
	jr	dir_parsefilename_end
.dir_parsefilename_wildextchar
	res	6,c			; wildcards present
	jr	dir_parsefilename_storeext
