XLIB trdos_file_allocate

LIB file_handles

include	"../lowio/lowio.def"
include	"trdos.def"

; returns HL = pointer to a free file handle, or carry reset if none are free
.trdos_file_allocate
	ld ix,file_handles
	ld b,file_numhandles
	ld de,file_trdos_size
	
	; is this handle free? (are the first two bytes 00?)
.test_handle
	ld a,(ix+0)
	or (ix+1)
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
	