XLIB fatfs_file_isopen

LIB file_handles

include "fatfs.def"

; ***************************************************************************
; * Subroutine to check if a file is open                                   *
; ***************************************************************************
; Entry: IY=directory handle, IX=partition handle, current entry is file
;        to be checked. Works by comparing directory handle contents.
; Exit: Fc=1 if file not open, Fc=0 if file open with A=mode flags
; ABCDEHL corrupt.

.fatfs_file_isopen
	ld	hl,file_handles
	ld	b,file_numhandles
.file_isopen_checknext
	push	hl			; save registers
	push	bc
	ld	d,iyh			; DE=dir handle to compare with
	ld	e,iyl
	ld	b,fdh_size
.file_isopen_checkloop
	ld	a,(de)
	cp	(hl)			; compare dir handle contents
	inc	de
	inc	hl
	jr	nz,file_isopen_notthisone
	djnz	file_isopen_checkloop
	ld	a,(hl)			; A=mode of matching filehandle
	and	a
	jr	z,file_isopen_notthisone ; not actually open
	pop	bc
	pop	hl
	ret				; with Fc=0, A=mode
.file_isopen_notthisone
	pop	bc
	pop	hl
	ld	de,ffh_size
	add	hl,de			; next filehandle
	djnz	file_isopen_checknext
	scf				; Fc=1, not open
	ret
