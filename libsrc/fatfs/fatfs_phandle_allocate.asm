XLIB fatfs_phandle_allocate

include	"fatfs.def"

; returns HL = pointer to a free partition handle, or carry reset if none are free
.fatfs_phandle_allocate
	ld ix,part_handles
	ld b,part_numhandles
	ld de,fph_size
	
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
	