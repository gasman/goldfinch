; extern BLOCK_DEVICE __LIB__ __FASTCALL__ *mbr_open_partition(PARTITION_INFO *partition_info)
XLIB mbr_open_partition

include "mbr.def"

LIB mbr_next_partition_entry
LIB read_block_asm
LIB write_block_asm

.mbr_open_partition
; enter with HL = partition_info struct
; return with HL = populated block device struct
	push hl	; get partition_info pointer into ix
	pop ix

	; get next free partition block device slot
	ld hl,(mbr_next_partition_entry)
	
	; populate partition_data first
	push hl	; save pointer to partition_data
	; copy underlying block device
	ex de,hl
	ld l,(ix + partition_info_block_device)	; get address of block device
	ld h,(ix + partition_info_block_device + 1)
	ld bc,blockdev_size
	ldir	; copy block device
	ex de,hl
	; copy LBA offset
	ld a,(ix + partition_info_start_block)
	ld (hl),a
	inc hl
	ld a,(ix + partition_info_start_block + 1)
	ld (hl),a
	inc hl
	ld a,(ix + partition_info_start_block + 2)
	ld (hl),a
	inc hl
	ld a,(ix + partition_info_start_block + 3)
	ld (hl),a
	inc hl
	; now populate the partition block device
	pop bc	; restore pointer to partition_data
	push hl	; save pointer to block device
	ld de,partition_blockdev_driver
	ld (hl),e	; fill in pointer to device driver
	inc hl
	ld (hl),d
	inc hl
	ld (hl),c ; fill in pointer to partition_data
	inc hl
	ld (hl),b
	inc hl
	ld (mbr_next_partition_entry),hl	; set pointer for next entry
	pop hl	; restore pointer to block device
	ret

; subroutine for translating a partition block number into a global device one
; by adding offset; used by partition_read_block and partition_write_block
.partition_translate
	; enter with ix = partition block device, bcde = block number
	; exit with ix = underlying block device, bcde = translated block number
	; A and IX corrupted
	push hl
	ld l,(ix + blockdev_data)	; read pointer to partition_data
	ld h,(ix + blockdev_data + 1)
	push hl	; get partition_data into ix;
	pop ix	; partition_data starts with a copy of the underlying block device,
		; so this also serves to make ix a pointer to that
	ld a,(ix + partition_data_offset)	; add partition_data_offset to BCDE
	add a,e
	ld e,a
	ld a,(ix + partition_data_offset + 1)
	adc a,d
	ld d,a
	ld a,(ix + partition_data_offset + 2)
	adc a,c
	ld c,a
	ld a,(ix + partition_data_offset + 3)
	adc a,b
	ld b,a
	pop hl
	ret

.partition_read_block
	; enter with IX = partition block device, BCDE = block num, HL = buffer
	push ix
	call partition_translate	; translate IX and BCDE
	call read_block_asm	; re-route through the generic read_block handler
	pop ix
	ret
.partition_write_block
	push ix
	call partition_translate
	call write_block_asm
	pop ix
	ret

.partition_blockdev_driver
	jp partition_read_block
	jp partition_write_block
