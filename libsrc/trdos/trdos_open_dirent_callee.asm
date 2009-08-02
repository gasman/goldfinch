; void trdos_open_dirent(DIRENT *dirent, FILE *file)

XLIB trdos_open_dirent_callee

LIB trdos_open_dirent

include	"trdos.def"

.trdos_open_dirent_callee
	pop hl
	pop de
	ex (sp),hl
	; enter with : hl = DIRENT *dirent
	;         de = FILE *file
	jp trdos_open_dirent

