XLIB fatfs_clus_extendchain

include "fatfs.def"

LIB fatfs_clus_allocate
LIB fatfs_fat_writefat

; ***************************************************************************
; * Add cluster to chain                                                    *
; ***************************************************************************
; On entry, IX=partition handle, BC=last cluster in current chain
; On exit, Fc=1 (success), with BC=new cluster number (added to chain)
; Or, Fc=1 (fail) and A=error
; ADEHL corrupted

.fatfs_clus_extendchain
	push	bc
	call	fatfs_clus_allocate		; allocate a new cluster
	ld	d,b
	ld	e,c			; DE=new cluster
	pop	bc			; BC=current cluster
	ret	nc			; exit if allocation error
	push	de			; save new cluster
	call	fatfs_fat_writefat		; store at end of chain
	pop	bc			; BC=cluster
	ret				; exit with any error from writing FAT
