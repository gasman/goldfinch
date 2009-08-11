XLIB fatfs_dir_path

include "fatfs.def"

LIB fatfs_dir_parsefilename
LIB fatfs_drive_getdirhandle
LIB fatfs_dir_getfirstmatch
LIB fatfs_dir_change
LIB fatfs_dir_entrydetails_callee
XREF fatfs_dir_entrydetails_asmentry
LIB fatfs_dir_next
LIB fatfs_dir_getentry
LIB fatfs_file_delete
XREF fatfs_file_delete_currententry
LIB fatfs_file_create_entry
LIB fatfs_clus_allocate
LIB buffer_writebuf
LIB fatfs_clus_erase
LIB fatfs_drive_getdircopy

; ***************************************************************************
; * FAT_PATH                                                                *
; ***************************************************************************
; Entry: HL=address of path (also address of 256-byte buffer for rc_path_get).
;	 A=reason code
; Exit: Fc=1 (success)
;       Fc=0 (failure), A=error
; ACDEHLIXIY corrupt

.fatfs_dir_path
	cp	rc_path_change
	jr	z,dir_path_change
	cp	rc_path_delete
	jr	z,dir_path_delete
	cp	rc_path_make
	jp	z,dir_path_make
	cp	rc_path_get
	jp	z,dir_path_get
	ld	a,rc_notimp
	and	a
	ret

.dir_path_change
	ex	de,hl
	ld	hl,dir_filespec1
	call	fatfs_dir_parsefilename	; parse the filespec, and get handles
	ret	nc			; exit if error
	push	af			; save sign flag
	push	iy			; save pathed directory handle
	call	fatfs_drive_getdirhandle
	push	iy
	pop	de			; DE=current directory handle
	pop	iy			; IY=pathed directory handle
	jr	nc,dir_path_change_fail	; exit if error
	pop	af			; restore sign flag, telling whether filename part present
	jp	p,dir_path_change_pathonly	; only a path, so skip the change
	push	de			; save current directory handle
	ld	de,dir_filespec1
	call	fatfs_dir_getfirstmatch	; find the directory to change to
	pop	de
	ret	nc			; exit if error
	ld	a,rc_notdir
	ccf
	ret	nz			; exit if not found
	push	de
	call	fatfs_dir_change		; if successful, change to it
	pop	de
.dir_path_change_pathonly
	push	iy
	pop	hl
	ld	bc,fdh_size
	ldir				; copy to current directory handle
	ret				; exit with any error from dir_change
.dir_path_change_fail
	pop	de			; discard flag
	ret


.dir_path_delete
	ex	de,hl
	ld	hl,dir_filespec1
	call	fatfs_dir_parsefilename	; parse the filespec, and get handles
	ret	nc			; exit if error
	ccf
	ld	a,rc_badname
	ret	nz			; or if wildcard present
	ret	p			; or if no filename part
	ld	de,dir_filespec1
	call	fatfs_dir_getfirstmatch	; find the directory to delete
	ret	nc			; exit if error
	ld	a,rc_notdir
	ccf
	ret	nz			; exit if not found
	push	iy
	pop	hl
	ld	de,sys_directory2
	ld	bc,fdh_size
	ldir				; copy to 2nd directory handle
	call	fatfs_dir_change		; enter the directory
	ret	nc
.dir_path_delete_checkempty
	call	fatfs_dir_entrydetails_asmentry + (fatfs_dir_entrydetails_callee-fatfs_dir_entrydetails_callee)	; get next entry details
	ret	nc
	jr	z,dir_path_delete_blankentry	; okay if unused
	ld	a,(hl)
	cp	'.'
	ld	a,rc_dirfull
.dir_path_delete_error
	scf
	ccf
	ret	nz			; error if not "." or ".." entry
.dir_path_delete_blankentry
	call	fatfs_dir_next
	jr	c,dir_path_delete_checkempty
	ld	iy,sys_directory2	; back to directory handle of parent
	call	fatfs_dir_getentry		; HL=entry address of directory
	ret	nc
	jp	fatfs_file_delete_currententry	; delete it and exit

.dir_path_make
	ex	de,hl
	ld	hl,dir_filespec1
	call	fatfs_dir_parsefilename	; parse the filespec, and get handles
	ret	nc			; exit if error
	ccf
	ld	a,rc_badname
	ret	nz			; or if wildcard present
	ret	p			; or if no filename part
	call	fatfs_file_create_entry	; create an entry for the new directory
	ret	nc			; exit if error
	call	fatfs_clus_allocate		; allocate a new cluster
	ret	nc			; exit if error
	push	bc
	call	fatfs_dir_getentry		; HL=address of entry
	ld	bc,direntry_attr
	add	hl,bc
	set	dirattr_dir,(hl)	; make it into a directory
	ld	bc,direntry_cluster-direntry_attr
	add	hl,bc
	pop	bc
	push	bc
	ld	(hl),c			; store cluster in directory entry
	inc	hl
	ld	(hl),b
	call	buffer_writebuf		; write directory entry
	pop	bc
	ret	nc
	push	bc
	call	fatfs_clus_erase		; erase the cluster, get HL=address of first entry
	pop	bc
	ret	nc
	push	hl
	ex	(sp),ix			; IX=address of entries
	set	dirattr_dir,(ix+direntry_attr)	; mark 1st two entries as directories
	set	dirattr_dir,(ix+direntry_attr+DIRENTRY_ENTRYSIZE)
	ld	(ix+direntry_cluster),c	; set directory's own cluster in 1st entry
	ld	(ix+direntry_cluster+1),b
	ld	c,(iy+fdh_clusstart)	; set parent's cluster in 2nd entry
	ld	b,(iy+fdh_clusstart+1)
	ld	(ix+direntry_cluster+DIRENTRY_ENTRYSIZE),c
	ld	(ix+direntry_cluster+1+DIRENTRY_ENTRYSIZE),b
	pop	ix			; restore partition handle
	ex	de,hl
	ld	hl,fspec_current
	ld	bc,11
	ldir				; copy filespec for "."
	ld	hl,DIRENTRY_ENTRYSIZE-11
	add	hl,de
	ex	de,hl			; DE=address of 2nd entry
	ld	hl,fspec_parent
	ld	bc,11
	ldir				; copy filespec for ".."
	jp	buffer_writebuf		; write buffer and exit with any error

.dir_path_get
	ld	a,(hl)			; first 1-2 chars may be user area - just ignore
	inc	hl
	cp	'1'
	jr	nz,dir_path_get_lowuser
	ld	a,(hl)
	inc	hl
.dir_path_get_lowuser
	cp	'0'
	jr	c,dir_path_get_notuser
	cp	'9'+1
	jr	nc,dir_path_get_notuser
	ld	a,(hl)			; first char is drive
	inc	hl
.dir_path_get_notuser
	ld	c,a
	ld	a,(hl)
	inc	hl
	cp	':'
	jp	nz,dir_path_baddrive
	ld	a,(hl)
	cp	$ff
	jp	nz,dir_path_baddrive
	push	hl			; save HL; also destination
	ld	a,c			; A=drive
	call	fatfs_drive_getdircopy	; IY=dirhandle copy, IX=partition handle for drive A
	pop	hl
	ret	nc			; exit if error
	ld	(hl),'/'		; append a segment delimiter
	inc	hl
	ld	(hl),$ff
	bit	7,(iy+fdh_flags)	; is this the root?
	scf
	ret	nz			; if so, exit with success
	dec	hl
	push	hl			; save earliest unusable address
	ld	de,253
	add	hl,de			; last usable address
	ld	(hl),$ff		; terminate
	dec	hl
.dir_path_nextparent
	push	hl			; save it
	ld	c,(iy+fdh_clusstart)
	ld	b,(iy+fdh_clusstart+1)	; get our start cluster
	push	bc
	ld	de,fspec_parent
	call	fatfs_dir_getfirstmatch
	jr	nc,dir_path_get_error
	ld	a,rc_notdir
	ccf
	jr	nz,dir_path_get_error	; exit if not found
	call	fatfs_dir_change		; change to parent directory
.dir_path_finddir
	jr	nc,dir_path_get_error
	call	fatfs_dir_entrydetails_asmentry + (fatfs_dir_entrydetails_callee-fatfs_dir_entrydetails_callee)
	jr	nc,dir_path_get_error
	jr	z,dir_path_blankentry	; skip unused entries
	ld	de,direntry_cluster
	add	hl,de			; HL points to cluster
	pop	bc
	push	bc
	ld	a,(hl)			; check if cluster matches ours
	inc	hl
	cp	c
	jr	nz,dir_path_blankentry
	ld	a,(hl)
	cp	b
	jr	z,dir_path_founddir
.dir_path_blankentry
	call	fatfs_dir_next		; loop to find directory
	jr	dir_path_finddir
.dir_path_founddir
	ld	bc,0+(direntry_ext+2)-(direntry_cluster+1)
	add	hl,bc			; HL points to end of extension
	pop	bc			; discard cluster
	pop	de			; fetch destination address
	ex	(sp),iy			; IY=earliest unusable address
	ld	a,'/'
	ld	b,1
	call	dir_path_inserttextA	; insert delimiter
	ld	b,3
.dir_path_parseext
	ld	a,(hl)
	dec	hl
	cp	' '
	call	nz,dir_path_inserttextA
	djnz	dir_path_parseext
	ld	b,8
.dir_path_parsename
	ld	a,(hl)
	dec	hl
	cp	' '
	call	nz,dir_path_inserttextA
	djnz	dir_path_parsename
	ex	(sp),iy			; IY=dir handle
	ex	de,hl			; HL=current destination
	bit	7,(iy+fdh_flags)	; have we reached the root?
	jr	z,dir_path_nextparent	; back if not
	pop	de
	inc	de			; address to shift up path to
	inc	hl			; start at last character inserted
	ld	bc,253
	ldir				; copy address up
	scf				; success!
	ret

.dir_path_get_error
	pop	bc
	pop	hl
	pop	hl
	ret				; TBD!

.dir_path_baddrive
	ld	a,rc_nodrive
	and	a
	ret

.dir_path_inserttext
	ld	a,(hl)
	dec	hl
.dir_path_inserttextA
	ld	(de),a
	ld	a,iyl
	cp	e
	jr	nz,dir_path_bufokay
	ld	a,iyh
	cp	d
	jr	nz,dir_path_bufokay
	ld	a,'*'			; replace with wildcard char
	ld	(de),a
	pop	hl			; discard return address
	pop	hl			; discard stacked IY
	scf				; success!
	ret
.dir_path_bufokay
	dec	de
	djnz	dir_path_inserttext
	ld	b,1			; fool DJNZ on return
	ret

.fspec_parent
	defm	"."
.fspec_current
	defm	".          "

