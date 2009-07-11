XLIB fatfs_clus_tobuf_noread

include "fatfs.def"

LIB fatfs_clus_getsector
LIB fatfs_buf_findbuf_noread

; ***************************************************************************
; * Get buffer for cluster sector, without reading disk                     *
; ***************************************************************************
; On entry, IX=partition handle, BC=cluster number and A=sector offset
; On exit, HL=sector address, Fc=1 (success)
; Or, Fc=0, failure (A=error)
; ABCDEHL corrupted.

.fatfs_clus_tobuf_noread
	call	fatfs_clus_getsector		; BCDE=logical sector
	ret	nc			; exit if error
	call	fatfs_buf_findbuf_noread	; get buffer without reading
	scf				; success!
	ret
