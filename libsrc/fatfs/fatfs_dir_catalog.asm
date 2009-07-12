XLIB fatfs_dir_catalog

include "fatfs.def"

LIB fatfs_dir_parsefilename
LIB fatfs_dir_matchname
LIB fatfs_dir_getfirstmatch
XREF fatfs_dir_getcurrentmatch
LIB fatfs_dir_home
LIB fatfs_dir_next
LIB fatfs_dir_entrydetails_callee
XREF fatfs_dir_entrydetails_asmentry

; ***************************************************************************
; * FAT_CATALOG                                                             *
; ***************************************************************************
; Entry: B=buffer size in entries, >=2
;        C=filter, bit 0=include system files if set
;        DE=address of buffer (1st entry initialised)
;        HL=address of filespec (wildcards allowed)
; Exit: Fc=1 (success), B=number of completed entries (inc preloaded)
;       Fc=0 (failure), A=error
; ACDEHLIXIY corrupt

; Uses attribute f8 to indicate if entry is a directory.
; Uses attribute t1 to indicate system (as normal) OR hidden.
; If no filename part is present after path, uses *.* as filespec (as +3DOS).

; TBD: Gives large filesizes as 65535K, so ResiDOS should query correct size?
; TBD: Doesn't sort alphabetically, as per +3DOS spec

defc	CATENTRY_SIZE=$0d

.fatfs_dir_catalog
	ld	a,1			; just pre-loaded entry "so far"
	push	af
	push	bc
	push	de
	ex	de,hl
	ld	hl,dir_filespec1
	call	fatfs_dir_parsefilename	; parse the filespec (wildcards ok), and get handles
	jp	nc,dir_catalog_fail
	jp	m,dir_catalog_gotname	; Fs=1 if a filename part was found
	ld	b,11
	ld	hl,dir_filespec1
.dir_catalog_allfiles
	ld	(hl),'?'		; else use ??????????? (*.*)
	inc	hl
	djnz	dir_catalog_allfiles
.dir_catalog_gotname
	pop	hl
	push	hl
	ld	a,(hl)
	and	a
	jr	z,dir_catalog_new	; zeroised pre-loaded, so fresh catalog
	ld	b,11
	ld	de,dir_filespec2
.dir_catalog_clearattrs
	ld	a,(hl)
	inc	hl
	res	7,a			; copy pre-loaded, masking off attribs
	ld	(de),a
	inc	de
	djnz	dir_catalog_clearattrs
	ld	de,dir_filespec2
	call	fatfs_dir_matchname		; does current entry match pre-loaded?
	jp	nc,dir_catalog_fail
	jr	z,dir_catalog_preloadok	; if so, move on
	ld	de,dir_filespec2
	call	fatfs_dir_getfirstmatch	; if not, find the one we were on
	jp	nc,dir_catalog_fail
	jr	z,dir_catalog_preloadok	; on if found it
.dir_catalog_nomatch
	pop	de			; discard stuff
	pop	de
	pop	bc			; B=entries
	scf				; success!
	ret
.dir_catalog_new
	call	fatfs_dir_home		; start at the first entry
	jp	nc,dir_catalog_fail
	jr	dir_catalog_begin
.dir_catalog_preloadok
	call	fatfs_dir_next		; skip to next entry
	jp	nc,dir_catalog_fail
.dir_catalog_begin
	pop	hl
	ld	bc,CATENTRY_SIZE
	add	hl,bc			; HL=second buffer entry
	push	hl
.dir_catalog_loop
	ld	de,dir_filespec1
	call	fatfs_dir_getcurrentmatch	; find another match
	jp	nc,dir_catalog_fail
	jr	nz,dir_catalog_nomatch
	call	fatfs_dir_entrydetails_asmentry + (fatfs_dir_entrydetails_callee-fatfs_dir_entrydetails_callee)	; HL=entry, A=attribs
	jp	nc,dir_catalog_fail
	pop	de			; DE=buffer address
	pop	bc			; C=filter
	push	bc
	bit	0,c
	jr	nz,dir_catalog_filterok	; including system files
	bit	dirattr_sys,a		; don't show system files
	jr	nz,dir_catalog_filterbad
	bit	dirattr_hid,a		; or hidden files
	jr	z,dir_catalog_filterok
.dir_catalog_filterbad
	push	de
	jr	dir_catalog_next	; skip current if filtered
.dir_catalog_filterok
	ld	bc,7
	ldir				; copy first 7 bytes of filename to buffer
	ld	c,a			; C=attributes
	ld	a,(hl)			; last filename char
	inc	hl
	bit	dirattr_dir,c		; directory?
	jr	z,dir_catalog_fn8
	set	7,a			; set bit 7 of f8 if so
.dir_catalog_fn8
	ld	(de),a
	inc	de
	ld	a,(hl)			; first extension char
	inc	hl
	bit	dirattr_ro,c		; read-only?
	jr	z,dir_catalog_ext1
	set	7,a			; set bit 7 of t1 if so
.dir_catalog_ext1
	ld	(de),a
	inc	de
	ld	a,(hl)			; 2nd extension char
	inc	hl
	bit	dirattr_sys,c		; system?
	jr	nz,dir_catalog_system
	bit	dirattr_hid,c		; or hidden?
	jr	z,dir_catalog_ext2
.dir_catalog_system
	set	7,a			; set bit 7 of t2 if so
.dir_catalog_ext2
	ld	(de),a
	inc	de
	ld	a,(hl)			; 3rd extension char
	inc	hl
	bit	dirattr_arc,c		; archived?
	jr	z,dir_catalog_ext3
	set	7,a			; set bit 7 of t3 if so
.dir_catalog_ext3
	ld	(de),a
	inc	de	
	ld	bc,direntry_filesize-direntry_attr
	add	hl,bc			; point to filesize
	ld	a,(hl)
	inc	hl
	add	a,255			; add 1023, to round up to nearest 1K
	ld	a,(hl)
	inc	hl
	adc	a,3
	ld	c,a
	ld	a,(hl)
	inc	hl
	adc	a,0
	ld	b,a
	ld	a,(hl)
	adc	a,0			; ABC=(filesize+1023)/256, in bytes
	srl	a
	rr	b
	rr	c
	srl	a
	rr	b
	rr	c			; ABC=filesize, in K
	and	a
	jr	z,dir_catalog_sizeok	; okay if 65535K or less
	ld	bc,$ffff		; else "approximate" to 65535K
.dir_catalog_sizeok
	ex	de,hl
	ld	(hl),c			; store in buffer
	inc	hl
	ld	(hl),b
	inc	hl			; HL=next buffer entry
	ex	de,hl
	pop	bc
	pop	af
	inc	a			; 1 more entry added
	cp	b			; is buffer full yet?
	scf
	ret	z			; done if so
	push	af
	push	bc
	push	de
.dir_catalog_next
	call	fatfs_dir_next		; skip to next entry
	jp	c,dir_catalog_loop
	cp	rc_eof
	jp	z,dir_catalog_nomatch	; finish if end of directory
	cp	rc_dirfull
	jp	z,dir_catalog_nomatch	; (end of root directory)
.dir_catalog_fail
	and	a			; Fc=0, fail
	pop	de
	pop	de
	pop	de
	ret
