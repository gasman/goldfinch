	org 0x8000
;	module border.asm
	
include "libsrc/divide/divide.def"
include "libsrc/block_device/block_device.def"
include "libsrc/fatfs/fatfs.def"

LIB divide_open_drive
XREF ASMDISP_DIVIDE_OPEN_DRIVE

LIB fatfs_init
LIB drive_init

;._main
	call fatfs_init
	; get handle to divide master device
	ld a,DIVIDE_DRIVE_MASTER
	call divide_open_drive + ASMDISP_DIVIDE_OPEN_DRIVE
	; returns block_device in hl
	ld de,partition_handle
	call drive_init	; populate the partition handle at de from the block device at hl

;	ld bc,0	; return with bc=0 if no error
;	ret c
;	ld c,a
	push de
	pop bc
	ret
	
.partition_handle
	defs fph_size + 1
	