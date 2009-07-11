XLIB fatfs_drive_getdircopy

include "fatfs.def"

LIB fatfs_drive_getdirhandle

; ***************************************************************************
; * Subroutine to get directory handle copy for drive                       *
; ***************************************************************************
; Entry: A=drive, 'A'-'P'
; Exit: Fc=1 (success), IY=copy of directory handle, IX=partition handle
;       Fc=0 (failure), A=error
; BCDEHL corrupt

.fatfs_drive_getdircopy
	call	fatfs_drive_getdirhandle	; IY=directory handle, IX=partition handle for drive A
	push	iy
	pop	hl
	ld	de,sys_directory
	ld	bc,fdh_size
	ldir				; copy to system handle
	ld	iy,sys_directory
	ret
