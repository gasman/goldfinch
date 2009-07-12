XLIB fatfs_dir_findvolumelabel

include "fatfs.def"

LIB fatfs_dir_root_callee
XREF fatfs_dir_root_asmentry
LIB fatfs_dir_entrydetails
LIB fatfs_dir_next

; ***************************************************************************
; * Find volume label                                                       *
; ***************************************************************************
; On entry, IX=partition handle
; On exit, Fc=1 (success), Fz=1 if not found, IY=dirhandle
;                          Fz=0 if found and HL=entry address, IY=dirhandle
; or, Fc=0 (failure) and A=error
; ABCDE corrupted.
	
.fatfs_dir_findvolumelabel
	ld	iy,sys_directory
	call	fatfs_dir_root_asmentry + (fatfs_dir_root_callee-fatfs_dir_root_callee)	; get root directory
	ret	nc
.dir_fvl_loop
	call	fatfs_dir_entrydetails	; get entry details
	ret	nc
	jr	z,dir_fvl_next		; skip unused entries
	bit	dirattr_vol,a		; is it a volume label?
	jr	z,dir_fvl_next
	and	dirattr_lfn		; ignore long filenames
	cp	dirattr_lfn
	scf
	ret	nz			; if not, exit with Fc=1, Fz=0 (found), HL=addr
.dir_fvl_next
	call	fatfs_dir_next		; move to next entry
	jr	c,dir_fvl_loop
	cp	rc_dirfull		; was error directory full?
	scf
	ret	z			; exit with Fc=1, Fz=1 (not found) if so
	ccf
	ret				; else exit with error
