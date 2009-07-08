XLIB buf_gethandle

include "fatfs.def"

; ***************************************************************************
; Subroutine to get a buffer handle                                         *
; ***************************************************************************
; On entry, A=buffer number (0..n-1)
; On exit, IY=buffer handle
; ADE corrupted.

.buf_gethandle
	ld	iy,buf_handles-fbh_size
	ld	de,fbh_size
	inc	a
.buf_gethandle_formaddr
	add	iy,de			; form address of location info
	dec	a
	jr	nz,buf_gethandle_formaddr
	ret
