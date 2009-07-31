; void trdos_read_dir(DIR *dir, DIRENT *dirent) - read the next entry from a directory
XLIB trdos_read_dir_callee

LIB trdos_read_dir

.trdos_read_dir_callee
	pop hl	; return address
	pop ix	; dirent
	ex (sp),hl	; get dir and replace return address
	jp trdos_read_dir
