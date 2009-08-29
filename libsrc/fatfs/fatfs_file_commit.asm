XLIB fatfs_file_commit

LIB buffer_flushbuffers
LIB buffer_writebuf
LIB fatfs_dir_getentry

include	"../lowio/lowio.def"
include	"fatfs.def"

; ***************************************************************************
; * Write file header, update directory & FAT and commit changes            *
; ***************************************************************************
; Entry: IY=file handle, IX=partition handle (residos doc said directory handle, but I think that's wrong)
; - both lowio.def
; Exit: Fc=1 (success)
;       Fc=0 (failure), A=error
; ABCDEHL corrupt

; TBD: Would be nice to update date & time if we had a RTC.
	
.fatfs_file_commit
	bit	fm_write,(iy+file_fatfs_mode)	; write access?
	jr	z,file_commit_readonly
;	bit	fm_header,(iy+ffh_mode) ; is there a header? - we don't have headers here
;	jr	z,file_commit_noheader	; on if not
;	call	file_header_write	; write the header
;	ret	nc			; exit if error
.file_commit_noheader
	call	buffer_flushbuffers	; ensure buffers flushed if writeable
	ret	nc			; exit if error
.file_commit_readonly
	bit	fm_entry,(iy+file_fatfs_mode)	; update dir entry?
	jr	z,file_commit_entryok	; on if not
	call	fatfs_dir_getentry		; get the directory entry
	ret	nc			; exit if error
	ld	bc,direntry_cluster
	add	hl,bc
	ex	de,hl
	push	iy
	pop	hl
	ld	bc,file_fatfs_clusstart
	add	hl,bc
	ld	c,2+4
	ldir				; copy cluster + size from handle
	call	buffer_writebuf		; write the buffer back
.file_commit_entryok
	scf				; success!
	ret
