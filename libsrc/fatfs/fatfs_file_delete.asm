XLIB fatfs_file_delete
XDEF fatfs_file_delete_currententry

include "fatfs.def"

LIB fatfs_dir_parsefilename
LIB fatfs_dir_getfirstmatch
XREF fatfs_dir_getnextmatch
LIB fatfs_file_isopen
LIB fatfs_dir_entrydetails_callee
XREF fatfs_dir_entrydetails_asmentry
LIB buffer_writebuf
LIB fatfs_clus_freechain

; ***************************************************************************
; * FAT_DELETE                                                              *
; ***************************************************************************
; Entry: HL=address of filename (wildcards allowed)
; Exit: Fc=1 (success)
;       Fc=0 (failure), A=error
; BCDEHLIXIY corrupt

.fatfs_file_delete
	ex	de,hl
	ld	hl,dir_filespec1
	call	fatfs_dir_parsefilename	; parse filename and get handles
	ret	nc			; exit if error
	jp	p,file_badname		; or if no filename part
	jr	nz,file_delete_wild	; move on if deleting with wildcards
.file_delete_1st
	ld	de,dir_filespec1
.file_delete_de
	call	fatfs_dir_getfirstmatch	; find file
	ret	nc			; exit if error
	ld	a,rc_nofile
	ccf
	ret	nz			; exit if not found
.file_delete_next
	call	fatfs_file_isopen
	ld	a,rc_denied
	ret	nc			; can't delete if file is open
	call	fatfs_dir_entrydetails_asmentry - (fatfs_dir_entrydetails_callee-fatfs_dir_entrydetails_callee)	; HL=entry, A=attribs
	ret	nc
	and	dirattr_nodeletemask
	ld	a,rc_nofile
	ret	nz			; can't delete R/O, hidden, sys, vol or dir
.fatfs_file_delete_currententry
	ld	(hl),direntry_deleted	; mark entry as deleted
	ld	de,direntry_cluster
	add	hl,de
	ld	c,(hl)
	inc	hl
	ld	b,(hl)			; BC=starting cluster
	push	bc
	call	buffer_writebuf		; update directory entry
	pop	bc
	ret	nc
	jp	fatfs_clus_freechain		; free the chain and exit with any error
.file_delete_wild
	call	file_delete_1st		; delete at least 1 file
	ret	nc			; exit if error
.file_delete_loop
	ld	de,dir_filespec1
	call	fatfs_dir_getnextmatch	; find next file
	ret	nc
	ret	nz			; exit with success if no more matches
	call	file_delete_next	; delete it
	ret	nc
	jr	file_delete_loop
.file_badname	
	ld	a,rc_badname
	and	a			; Fc=0, failure
	ret
