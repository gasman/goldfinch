XLIB startup

LIB buffer_emptybuffers
LIB fatfs_init
LIB divide_open_drive_asm
LIB fatfs_fsopen_asmentry
LIB open_root_dir_asmentry

LIB asciiprint_setpos
LIB asciiprint_print
LIB asciiprint_newline

LIB current_filesystem
LIB current_dir

LIB dir_page_start
LIB dir_this_page_count
LIB dir_selected_entry

LIB clear_screen

LIB firmware_is_active

LIB firmware_tmp_volume
LIB firmware_tmp_partition_info

LIB mbr_init
LIB mbr_has_boot_signature
LIB mbr_get_partition_info_asm
LIB mbr_open_partition

LIB asciiprint_font
LIB font_is_in_ram
LIB exit_ret
LIB divide_flush_buffers

LIB error_popup

include "../../libsrc/divide/divide.def"
include "../../libsrc/mbr/mbr.def"
include "../../libsrc/errors/errors.def"

.startup

; flush DivIDE buffers, giving a nice long delay to let the hardware
; settle down into whatever state it evidently needs to settle down into
	call divide_flush_buffers

	ld bc,0x7ffd	; set paging register
	ld a,0x10	; 48K ROM enabled, paging active, page 0 paged in
	out (c),a	; force usr0 mode - otherwise entering usr0 in 128K Basic gets us stuck in a loop
	
	xor a
	out (0xe3),a	; page in DivIDE RAM page 0
	
	ld bc,0x7ffe
	in a,(c)	; test for space; force startup if pressed
	and 0x01
	jr nz,no_force_startup
	ld (firmware_is_active),a
	ld (font_is_in_ram),a
	ld hl,0
	ld (current_dir),hl
	; wait for space to be released
.release_space
	in a,(c)
	and 0x01
	jr z,release_space
.no_force_startup
	
	ld a,(firmware_is_active)
	cp 0x42
	ret z	; skip startup if already active
	
	; check whether font is in RAM ready to be copied to DivIDE RAM
	ld a,(font_is_in_ram)
	dec a
	jr z,copy_font_to_divide

; copy copy_font routine to RAM
	ld hl,copy_font
	ld de,0x4000
	push de
	ld bc,copy_font_end - copy_font
	ldir
	ld a,1
	ld (font_is_in_ram),a
	jp exit_ret	; jump to 0x4000 to copy font to RAM, then return here
	
.copy_font_to_divide
	ld hl,0x4100
	ld de,asciiprint_font
	ld bc,0x0300
	ldir
	
	call buffer_emptybuffers
	call fatfs_init
	call mbr_init
	ld hl,0
	ld (dir_page_start),hl
	xor a
	ld (dir_selected_entry),a
	
	ld a,DIVIDE_DRIVE_MASTER
	call divide_open_drive_asm
	; returns block device in hl
	ld (firmware_tmp_volume),hl
	
	ld ix,current_filesystem
	; try to open the whole drive as a FAT volume
	call fatfs_fsopen_asmentry
	jr c,fat_whole_volume_ok
	
	; failing that, look for an MBR
	ld hl,(firmware_tmp_volume)
	call mbr_has_boot_signature
	jr nc,fat_init_error
	ld a,l
	or a
	jr z,mbr_unknown

	; loop over the four partition records in the MBR, looking for FAT
	ld c,0
.check_next_partition_record
	push bc
	ld ix,(firmware_tmp_volume)
	ld hl,firmware_tmp_partition_info
	call mbr_get_partition_info_asm
	pop bc
	; checked whether the received partition record has one of the known type codes for FAT16
	ld a,(firmware_tmp_partition_info + partition_info_partition_type)
	cp partition_type_fat16_small
	jr z,found_fat_partition
	cp partition_type_fat16_large
	jr z,found_fat_partition
	cp partition_type_fat16_lba
	jr z,found_fat_partition
	inc c	; no match, so try again with the next record
	bit 2,c	; while c < 4
	jr z,check_next_partition_record

; no fat partitions found
	ld a,err_no_usable_partitions
	jr fat_init_error
	
.found_fat_partition
	ld hl,firmware_tmp_partition_info
	call mbr_open_partition	; returns block device for partition in HL
	ld ix,current_filesystem
	; open the partition as a FAT volume
	call fatfs_fsopen_asmentry
	
.fat_whole_volume_ok
	ld hl,current_filesystem
	ld de,current_dir
	call open_root_dir_asmentry
	
.resume_without_fat
	; Set up vector table to test for IM2
	ld hl,0x3d00
	ld de,0x3d01
	ld bc,0x0100	; fill 0x0101 bytes of 0x3e
	ld (hl),0x3e
	ldir
	ld hl,0xc93c	; opcodes for INC A; RET
	ld (0x3e3e),hl	; store at 0x3e3e (destination of vector table)
	
	; flag firmware as active
	ld a,0x42
	ld (firmware_is_active),a
	
	ret

.mbr_unknown
	ld a,err_unrecognised_boot_record
.fat_init_error
	call error_popup
	jr resume_without_fat

.copy_font
	ld hl,0x3d00
	ld de,0x4100
	ld bc,0x0300
	ldir
	rst 0x00
.copy_font_end
