XLIB fatfs_file_close

LIB fatfs_file_commit

include "../lowio/lowio.def"

; ***************************************************************************
; * FAT_CLOSE                                                               *
; ***************************************************************************
; Entry: IY = file handle
; Exit: Fc=1 (success)
;       Fc=0 (failure), A=error
; ABCDEHLIXIY corrupt

.fatfs_file_close
	; get partition handle into ix
	ld l,(iy + filesystem_fatfs_phandle)
	ld h,(iy + filesystem_fatfs_phandle + 1)
	push hl
	pop ix
	
	call	fatfs_file_commit		; update header, dir & commit
.file_close_entryok
	ld	(iy+file_fatfs_mode),0		; free the filenumber
	ret
