XLIB clus_readtobuf

include "fatfs.def"

LIB clus_getsector
LIB buf_findbuf

; ***************************************************************************
; * Read sector from cluster                                                *
; ***************************************************************************
; On entry, IX=partition handle, BC=cluster number and A=sector offset
; On exit, HL=sector address, Fc=1 (success)
; Or, Fc=0, failure (A=error)
; ABCDEHL corrupted.

.clus_readtobuf
	call	clus_getsector		; BCDE=logical sector
	ret	nc			; exit if error
	jp	buf_findbuf		; read to buffer
