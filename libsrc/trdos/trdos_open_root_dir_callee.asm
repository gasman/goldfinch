; void trdos_open_root_dir(FILESYSTEM *fs, DIR *dir) - open the root directory of the filesystem
XLIB trdos_open_root_dir_callee

LIB trdos_open_root_dir

.trdos_open_root_dir_callee
	pop hl	; return address
	pop de	; dir
	ex (sp),hl	; get fs and replace return address
	jp trdos_open_root_dir
