; void __CALLEE__ trdos_fsopen_callee(BLOCK_DEVICE *device, FILESYSTEM *fs)
; open a block device for access as a trdos file system

XLIB trdos_fsopen_callee
XDEF trdos_fsopen_asmentry

LIB trdos_open_root_dir
LIB trdos_read_dir
LIB trdos_open_dirent
LIB trdos_read_file
LIB trdos_close_file

include	"../lowio/lowio.def"

.trdos_fsopen_callee

	pop hl
	pop ix
	ex (sp),hl

   ; enter : hl = BLOCK_DEVICE *device
   ;         ix = FILESYSTEM *fs
   ; uses  : hl, ix
   
.trdos_fsopen_asmentry
	; set pointer to the trdos filesystem driver
	ld de,trdos_filesystem_driver
	ld (ix+filesystem_driver),e
	ld (ix+filesystem_driver+1),d
	; for trdos, the 'data' field is a pointer to the block_device
	ld (ix+filesystem_data),l
	ld (ix+filesystem_data+1),h
	ret

.trdos_filesystem_driver
	; jump table to fs routines
	jp trdos_open_root_dir
	jp trdos_read_dir
	jp trdos_open_dirent
	jp trdos_read_file
	jp trdos_close_file
	