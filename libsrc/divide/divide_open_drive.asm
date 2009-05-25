; BLOCK_DEVICE __LIB__ __FASTCALL__ *divide_open_drive_callee(unsigned char drive_number);

XLIB divide_open_drive
XDEF ASMDISP_DIVIDE_OPEN_DRIVE

LIB divide_read_sector_callee
XREF ASMDISP_DIVIDE_READ_SECTOR_CALLEE

DEFC DIVIDE_DRIVE_MASTER = 0x40
DEFC DIVIDE_DRIVE_SLAVE = 0x50

.divide_open_drive

	ld a,l
	
	; enter : a = drive ID code (DIVIDE_DRIVE_MASTER or DIVIDE_DRIVE_SLAVE)
	; exit  : hl = address of BLOCK_DEVICE structure
	; uses  : 
	
.asmentry
	ld hl,master_drive_block_device
	cp DIVIDE_DRIVE_MASTER
	ret z
	ld hl,slave_drive_block_device
	ret

DEFVARS 0
{  
	blockdevice_blockdevicetype     ds.w 1	; pointer to a block_device_type structure
	blockdevice_data	ds.w 1	; Pointer (or other value) for arbitrary data relating to this device
	SIZEOF_blockdevice	; total size of data structure
}

DEFVARS 0
{  
	blockdevicetype_read_block     ds.w 1	; pointer to a read_block function handler
	SIZEOF_blockdevicetype	; total size of data structure
}

; define the block_device_type structure for DivIDE drives
.divide_drive_block_device_type
	DEFW divide_read_block

.master_drive_block_device
	DEFW divide_drive_block_device_type
	DEFB DIVIDE_DRIVE_MASTER
	DEFB 0

.slave_drive_block_device
	DEFW divide_drive_block_device_type
	DEFB DIVIDE_DRIVE_SLAVE
	DEFB 0

; a function (CALLER linkage) with signature:
; void read_block(BLOCK_DEVICE *device, void *buffer, unsigned long block_number)
.divide_read_block
	pop af	; read return address
	pop de
	pop bc	; read block_number into BCDE
	pop hl	; read buffer pointer into HL
	pop ix	; read device pointer into HL
	push ix	; restore stack frame
	push hl
	push bc
	push de
	push af
	
	ld a,(ix+2)	; read drive identifier from device structure
	jp divide_read_sector_callee + ASMDISP_DIVIDE_READ_SECTOR_CALLEE

DEFC ASMDISP_DIVIDE_OPEN_DRIVE = asmentry - divide_open_drive
