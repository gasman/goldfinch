; void __CALLEE__ trdos_fsopen_callee(BLOCK_DEVICE *device, TRDOS_FILESYSTEM *fs)
; open a block device for access as a trdos file system

XLIB trdos_fsopen_callee
XDEF ASMDISP_TRDOS_FSOPEN_CALLEE

include	"trdos.def"

.trdos_fsopen_callee

	pop hl
	pop ix
	ex (sp),hl

   ; enter : hl = BLOCK_DEVICE *device
   ;         ix = TRDOS_FILESYSTEM *fs
   ; uses  : hl, ix
   
.asmentry
	; fs->block_device = device;
	ld (ix+trdfs_block_device),l
	ld (ix+trdfs_block_device+1),h
	ret

DEFC ASMDISP_TRDOS_FSOPEN_CALLEE = asmentry - trdos_fsopen_callee
