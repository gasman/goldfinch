; BLOCK_DEVICE __LIB__ __FASTCALL__ *divide_open_drive_callee(unsigned char drive_number);

XLIB divide_open_drive
XDEF divide_open_drive_asmentry
XDEF ASMDISP_DIVIDE_OPEN_DRIVE

include	"divide.def"

LIB divide_read_block_callee
XREF divide_read_block_asmentry

.divide_open_drive

	ld a,l
	
	; enter : a = drive ID code (DIVIDE_DRIVE_MASTER or DIVIDE_DRIVE_SLAVE)
	; exit  : hl = address of BLOCK_DEVICE structure
	; uses  : 
	
.divide_open_drive_asmentry
	; return a pointer to the master or slave block device, depending on the ID passed in A
	ld hl,master_drive_block_device
	cp DIVIDE_DRIVE_MASTER
	ret z
	ld hl,slave_drive_block_device
	ret
DEFC ASMDISP_DIVIDE_OPEN_DRIVE = divide_open_drive_asmentry - divide_open_drive

.master_drive_block_device
	DEFW divide_block_device_driver
	DEFB DIVIDE_DRIVE_MASTER
	DEFB 0

.slave_drive_block_device
	DEFW divide_block_device_driver
	DEFB DIVIDE_DRIVE_SLAVE
	DEFB 0

; 'device driver' for DivIDE drives: a lookup table to the asm entry points
.divide_block_device_driver
	jp divide_read_block_asmentry + (divide_read_block_callee - divide_read_block_callee)	; read_block
