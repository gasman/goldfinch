; void trdos_open_dirent(DIRENT *dirent, FILE *file)

XLIB trdos_open_dirent_callee

LIB trdos_open_dirent

.trdos_open_dirent_callee
	pop ix
	pop de
	ex (sp),ix
	; enter with : ix = DIRENT *dirent
	;         de = FILE *file
	jp trdos_open_dirent

