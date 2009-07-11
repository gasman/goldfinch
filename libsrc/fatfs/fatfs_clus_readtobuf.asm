XLIB fatfs_clus_readtobuf

include "fatfs.def"

LIB fatfs_clus_getsector
LIB fatfs_buf_findbuf

; ***************************************************************************
; * Read sector from cluster                                                *
; ***************************************************************************
; On entry, IX=partition handle, BC=cluster number and A=sector offset
; On exit, HL=sector address, Fc=1 (success)
; Or, Fc=0, failure (A=error)
; ABCDEHL corrupted.

.fatfs_clus_readtobuf
	call	fatfs_clus_getsector		; BCDE=logical sector
	ret	nc			; exit if error
	jp	fatfs_buf_findbuf		; read to buffer
