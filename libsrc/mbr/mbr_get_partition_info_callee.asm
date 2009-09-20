; extern void __LIB__ __CALLEE__ mbr_get_partition_info_callee(BLOCK_DEVICE *device, unsigned char partition_number, PARTITION_INFO *partition_info);

XLIB mbr_get_partition_info_callee
XDEF mbr_get_partition_info_asm

LIB buffer_findbuf

.mbr_get_partition_info_callee
	pop de	; return address
	pop hl	; partition info struct
	pop bc	; partition number
	pop ix	; block device
	push de	; restore return address
; enter with ix = block device, c = partition number, hl = partition_info
.mbr_get_partition_info_asm
	; store a pointer to the block device at the start of partition_info
	ld a,ixl
	ld (hl),a
	inc hl
	ld a,ixh
	ld (hl),a
	inc hl
	push hl
	push bc
	ld b,0	; request block 0
	ld c,b
	ld d,b
	ld e,b
	call buffer_findbuf	; returns address of sector data in HL
	ex de,hl
	pop hl	; restore partition number
	ld h,0
	add hl,hl	; multiply by 16
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,de	; add to address
	ld de,0x01be + 0x04	; 0x01be = start of partition table; 0x04 = offset of partition_type byte
	add hl,de
	pop de	; restore partition_info pointer
	ldi	; copy partition_type byte
	inc hl	; advance past CHS address
	inc hl
	inc hl
	ld bc,4	; copy LBA address
	ldir
	ret
	