XLIB dir_getentry

include "fatfs.def"

LIB clus_readtobuf
LIB buf_findbuf

; ***************************************************************************
; * Get address of current entry                                            *
; ***************************************************************************
; On entry, IY=directory handle, IX=partition handle
; On exit, Fc=1 (success) and HL=address
; or, Fc=0 (failure) and A=error
; ABCDE corrupted.

.dir_getentry
	bit	7,(iy+fdh_flags)	; root directory?
	jr	nz,dir_getentry_root
	ld	c,(iy+fdh_cluster)
	ld	b,(iy+fdh_cluster+1)
	ld	a,(iy+fdh_sector)
	call	clus_readtobuf		; get sector to buffer
.dir_getentry_formaddr
	ret	nc			; exit if error
	ld	e,(iy+fdh_entry)
	ld	d,0			; DE=entry number
	ex	de,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl			; HL=32*entry number
	add	hl,de			; HL=address
	scf				; success!
	ret
.dir_getentry_root
	ld	l,(ix+fph_root_start)
	ld	h,(ix+fph_root_start+1)
	ld	a,(ix+fph_root_start+2)
	ld	c,(iy+fdh_cluster)
	ld	b,(iy+fdh_cluster+1)
	add	hl,bc
	adc	a,0			; AHL=sector to read
	ex	de,hl
	ld	c,a
	ld	b,0			; BCDE=sector to read
	call	buf_findbuf		; read the sector
	jr	dir_getentry_formaddr
