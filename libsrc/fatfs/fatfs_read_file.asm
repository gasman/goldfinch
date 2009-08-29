; int fatfs_read_file(FILE *file, void *buf, unsigned int nbyte)
XLIB fatfs_read_file

LIB fatfs_file_checkfilepos
LIB fatfs_file_getvalidaddr
LIB fatfs_file_addfpos
LIB tmp_rwaddr
LIB tmp_rwsize
LIB tmp_rwpossible

include	"fatfs.def"
include	"../lowio/lowio.def"

; enter with: IX = file, DE = buf, BC = nbyte
; returns hl=0 and carry reset if end of file
.fatfs_read_file
	push ix	; subsequent code (from residos fatfs) expects file handle in iy.
		; TODO: convert code to ix if possible, so we don't have to do this switch
	pop iy
	; also, expects partition handle (fph) in ix; this is pointed to by filesystem_data,
	; which is embedded in the file handle
	ld l,(iy+file_filesystem+filesystem_data)
	ld h,(iy+file_filesystem+filesystem_data+1)
	push hl
	pop ix
	
	; also, subsequent code expects addr in hl, size in de
	ex de,hl
	ld d,b
	ld e,c

	ld	(tmp_rwaddr),hl		; save address
	ld	(tmp_rwsize),de		; save size
	bit	fm_read,(iy+file_fatfs_mode)	; is access mode okay?
	jp	z,file_read_access
	call	fatfs_file_checkfilepos	; Fc=1 if filesize > filepos (okay)
	jr	nc,file_read_eof
	ld	c,(iy+file_fatfs_filepos)
	ld	b,(iy+file_fatfs_filepos+1)
	ld	l,(iy+file_fatfs_filesize)
	ld	h,(iy+file_fatfs_filesize+1)
	and	a
	sbc	hl,bc
	ex	de,hl			; DE=low word of bytes remaining in file
	ld	c,(iy+file_fatfs_filepos+2)
	ld	b,(iy+file_fatfs_filepos+3)
	ld	l,(iy+file_fatfs_filesize+2)
	ld	h,(iy+file_fatfs_filesize+3)
	sbc	hl,bc			; HLDE=bytes remaining in file
	ld	hl,(tmp_rwsize)		; HL=bytes to read
	jr	nz,file_read_readmax	; if bytes remaining in file >= 64K, we can read the whole lot
	ld	a,h
	or	l
	jr	z,file_read_readremaining ; if want to read 64K, just read all that's left
	and	a
	sbc	hl,de
.file_read_readremaining
	ex	de,hl
	jr	nc,file_read_readmax	; if bytes remaining < what we want, read all that's left
	add	hl,de			; else, read what we want
.file_read_readmax
	; At this point, HL=number of bytes we can read from the file (0==64K)
	ld	(tmp_rwpossible),hl
	call	fatfs_file_getvalidaddr	; get HL=address, DE=512-bytes
	jr	nc,file_read_error	; exit if error
	push	hl
	ld	hl,512
	and	a
	sbc	hl,de			; HL=bytes in sector
	pop	de			; DE=buffer address
	ld	bc,(tmp_rwpossible)	; BC=bytes readable: May be zero==64K
	ld	a,b
	or	c
	jr	z,file_read_readallbuf
	sbc	hl,bc
	jr	nc,file_read_readable	; buffer contains all rest of file
	add	hl,bc
.file_read_readallbuf
	ld	b,h
	ld	c,l			; BC=bytes to read from this buffer
.file_read_readable
	push	bc
	ld	hl,(tmp_rwaddr)
	ex	de,hl
	ldir				; copy bytes from buffer
	ld	(tmp_rwaddr),de		; update address
	pop	bc
	ld	hl,(tmp_rwsize)
	and	a
	sbc	hl,bc
	ld	(tmp_rwsize),hl		; update size left to read
	push	af			; save flag
	push	bc
	call	fatfs_file_addfpos		; update filepointer
	pop	bc
	pop	af			; restore finished flag
	jr	z,file_read_done	; finished if size=0
	ld	hl,(tmp_rwpossible)
	and	a
	sbc	hl,bc
	jr	z,file_read_eof		; also finished if can't read any more
	jr	file_read_readmax	; back for next sector

.file_read_done
	scf				; success!
	ret
.file_read_eof
	ld	a,rc_eof		; EOF
	jr	file_read_error
.file_read_access
	ld	a,rc_number		; access mode error
.file_read_error
	ld	de,(tmp_rwsize)		; get bytes remaining
	and	a			; Fc=0, failure
	ret

