XLIB fatfs_file_getfilepos

include	"../lowio/lowio.def"

; ***************************************************************************
; * FAT_GET_POSITION                                                        *
; ***************************************************************************
; Entry: IY=filehandle, IX=partition handle (both lowio.def)
; Exit: Fc=1 (success), DEHL=filepos (NB: This exceeds +3DOS specification!)
;       Fc=0 (failure), A=error
; ABCIXIY corrupt
; Can enter at file_getfilepos if IY=filehandle already,
; in which case IX + IY are preserved

;.file_get_position
;	call	file_gethandles		; handles to IY & IX
.fatfs_file_getfilepos
	ld	l,(iy+file_fatfs_filepos)
	ld	h,(iy+file_fatfs_filepos+1)
	ld	e,(iy+file_fatfs_filepos+2)
	ld	d,(iy+file_fatfs_filepos+3)	; DEHL=filepos
	scf				; success!
	ret
