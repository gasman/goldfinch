XLIB fatfs_dir_getfree

include "fatfs.def"

LIB fatfs_dir_home
LIB fatfs_dir_entrydetails_callee
XREF fatfs_dir_entrydetails_asmentry
LIB fatfs_dir_next
LIB fatfs_clus_extendchain
LIB fatfs_clus_erase

; ***************************************************************************
; * Get free entry                                                          *
; ***************************************************************************
; On entry, IY=directory handle, IX=partition handle
; On exit, Fc=1 (success), HL=entry address
; or, Fc=0 (failure) and A=error
; ABCDE corrupted.
; TBD: Could be more efficient if maintained a "last allocated" as per clusters.

.fatfs_dir_getfree
	call	fatfs_dir_home		; start at top of directory
.dir_getfree_loop
	call	fatfs_dir_entrydetails_asmentry + (fatfs_dir_entrydetails_callee-fatfs_dir_entrydetails_callee)	; check current entry
	ret	nc			; exit if error
	ret	z			; exit if entry is available
	call	fatfs_dir_next		; next entry
	jr	c,dir_getfree_loop	; keep going until out of entries
	bit	7,(iy+fdh_flags)	; root directory?
	ret	nz			; if so, exit with directory full error
	ld	c,(iy+fdh_cluster)
	ld	b,(iy+fdh_cluster+1)	; BC=last cluster in directory
	call	fatfs_clus_extendchain	; add another
	ret	nc			; exit if error
	ld	(iy+fdh_cluster),c	; store new cluster
	ld	(iy+fdh_cluster+1),b
	xor	a
	ld	(iy+fdh_sector),a	; set first entry in new cluster
	ld	(iy+fdh_entry),a
	jp	fatfs_clus_erase		; erase cluster, exiting with HL=address
					;  of first entry in first sector
