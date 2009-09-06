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

include "../../libsrc/divide/divide.def"

.startup
	ld bc,0x7ffd	; set paging register
	ld a,0x10	; 48K ROM enabled, paging active, page 0 paged in
	out (c),a	; force usr0 mode - otherwise entering usr0 in 128K Basic gets us stuck in a loop
	
	call buffer_emptybuffers
	call fatfs_init
	ld hl,0
	ld (dir_page_start),hl
	xor a
	ld (dir_selected_entry),a
	
	ld a,DIVIDE_DRIVE_MASTER
	call divide_open_drive_asm
	; returns block device in hl
	
	ld ix,current_filesystem
	call fatfs_fsopen_asmentry

	ld hl,current_filesystem
	ld de,current_dir
	call open_root_dir_asmentry
	
	ret
