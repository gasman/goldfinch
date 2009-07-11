XLIB fatfs_buf_findbuf_noread
XDEF fatfs_buf_locatebuf

include "fatfs.def"

LIB fatfs_buf_setmru
LIB fatfs_buf_flushone

; ***************************************************************************
; * Subroutine to get buffer for sector, without reading from disk          *
; ***************************************************************************
; On entry, BCDE=sector required, IX=partition handle
; On exit, HL=address of buffer
;          Fc=1 if buffer contents are valid, Fc=0 if needs reading.
; No errors possible.
; This will update the MRU list
; ABCDEHL corrupted.
; Enter at buf_locatebuf to also return buffer handle in IY.
; TBD: Maybe this should be able to return an error, as it does do disk writes.

.fatfs_buf_findbuf_noread
	push	iy
	call	fatfs_buf_locatebuf
	pop	iy
	ret
.fatfs_buf_locatebuf
	ld	iy,buf_handles
	ld	l,buf_numbufs
.buf_fb_search
	bit	bufflag_inuse,(iy+fbh_flags)
	jr	z,buf_fb_mismatch	; no match if not in use
	ld	a,(iy+fbh_sector)	; check sector (lsf first)
	cp	e
	jr	nz,buf_fb_mismatch
	ld	a,(iy+fbh_sector+1)
	cp	d
	jr	nz,buf_fb_mismatch
	ld	a,(iy+fbh_sector+2)
	cp	c
	jr	nz,buf_fb_mismatch
	ld	a,(iy+fbh_sector+3)
	cp	b
	jr	nz,buf_fb_mismatch
	ld	a,ixl			; check partition handle (lsf first)
	cp	(iy+fbh_phandle)
	jr	nz,buf_fb_mismatch
	ld	a,ixh
	cp	(iy+fbh_phandle+1)
	jr	nz,buf_fb_mismatch
	ld	a,buf_numbufs
	sub	l			; A=buffer number
	call	fatfs_buf_setmru		; set MRU, get address
	scf				; Fc=1, buffer contents valid
	ret
.buf_fb_mismatch
	push	bc
	ld	bc,fbh_size
	add	iy,bc			; step to location of next buffer
	pop	bc
	dec	l
	jr	nz,buf_fb_search	; check remaining buffers
	ld	a,(buf_mrulist+buf_numbufs-1)	; A=LRU buffer number
	push	de
	call	fatfs_buf_flushone		; leaves IY=buffer handle
	pop	hl			; BCHL=sector
	set	bufflag_inuse,(iy+fbh_flags)
	res	bufflag_upd,(iy+fbh_flags)
	ld	a,ixl
	ld	(iy+fbh_phandle),a	; store partition handle
	ld	a,ixh
	ld	(iy+fbh_phandle+1),a
	ld	(iy+fbh_sector),l	; and sector
	ld	(iy+fbh_sector+1),h
	ld	(iy+fbh_sector+2),c
	ld	(iy+fbh_sector+3),b
	ld	a,(buf_mrulist+buf_numbufs-1)	; A=LRU buffer again
	call	fatfs_buf_setmru		; set MRU, get address to HL
	and	a			; Fc=0, contents not valid
	ret
