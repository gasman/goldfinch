XLIB fatfs_file_allocate

LIB file_handles

include	"../lowio/lowio.def"
include	"fatfs.def"

; returns HL = pointer to a free file handle, or carry reset if none are free
.fatfs_file_allocate
	ld ix,file_handles
	ld b,file_numhandles
	ld de,file_fatfs_size
	
	; is this handle free? (is the mode byte 00?)
.test_handle
	ld a,(ix+file_fatfs_mode)
	or a
	jr z,found
	add ix,de
	djnz test_handle
	or a	; fail
	ret
	
.found
	push ix
	pop hl
	scf
	ret
	