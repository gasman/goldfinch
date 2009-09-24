XLIB fatfs_file_is_eof

LIB fatfs_file_checkfilepos

; enter with IY = file handle
; return HL = 0x0001 and carry reset if EOF, 0x0000 and carry set otherwise
.fatfs_file_is_eof
	call fatfs_file_checkfilepos
	ld hl,0x0000
	ret c
	inc hl
	ret
	