XLIB file_delete
XDEF file_delete_currententry

include "fatfs.def"

LIB dir_parsefilename
LIB dir_getfirstmatch
XREF dir_getnextmatch
LIB file_isopen
LIB dir_entrydetails
LIB buf_writebuf
LIB clus_freechain

; ***************************************************************************
; * FAT_DELETE                                                              *
; ***************************************************************************
; Entry: HL=address of filename (wildcards allowed)
; Exit: Fc=1 (success)
;       Fc=0 (failure), A=error
; BCDEHLIXIY corrupt

.file_delete
	ex	de,hl
	ld	hl,dir_filespec1
	call	dir_parsefilename	; parse filename and get handles
	ret	nc			; exit if error
	jp	p,file_badname		; or if no filename part
	jr	nz,file_delete_wild	; move on if deleting with wildcards
.file_delete_1st
	ld	de,dir_filespec1
.file_delete_de
	call	dir_getfirstmatch	; find file
	ret	nc			; exit if error
	ld	a,rc_nofile
	ccf
	ret	nz			; exit if not found
.file_delete_next
	call	file_isopen
	ld	a,rc_denied
	ret	nc			; can't delete if file is open
	call	dir_entrydetails	; HL=entry, A=attribs
	ret	nc
	and	dirattr_nodeletemask
	ld	a,rc_nofile
	ret	nz			; can't delete R/O, hidden, sys, vol or dir
.file_delete_currententry
	ld	(hl),direntry_deleted	; mark entry as deleted
	ld	de,direntry_cluster
	add	hl,de
	ld	c,(hl)
	inc	hl
	ld	b,(hl)			; BC=starting cluster
	push	bc
	call	buf_writebuf		; update directory entry
	pop	bc
	ret	nc
	jp	clus_freechain		; free the chain and exit with any error
.file_delete_wild
	call	file_delete_1st		; delete at least 1 file
	ret	nc			; exit if error
.file_delete_loop
	ld	de,dir_filespec1
	call	dir_getnextmatch	; find next file
	ret	nc
	ret	nz			; exit with success if no more matches
	call	file_delete_next	; delete it
	ret	nc
	jr	file_delete_loop
.file_badname	
	ld	a,rc_badname
	and	a			; Fc=0, failure
	ret
