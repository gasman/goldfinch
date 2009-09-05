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

LIB clear_screen

include "../../libsrc/divide/divide.def"

.startup
	ld bc,0x7ffd	; set paging register
	ld a,0x10	; 48K ROM enabled, paging active, page 0 paged in
	out (c),a	; force usr0 mode - otherwise entering usr0 in 128K Basic gets us stuck in a loop
	
	call clear_screen
	ld bc,0
	call asciiprint_setpos
	
	ld hl,msg_initialising
	call asciiprint_print
	call asciiprint_newline

	call buffer_emptybuffers
	call fatfs_init
	
	ld hl,msg_opening_drive
	call asciiprint_print
	call asciiprint_newline

	ld a,DIVIDE_DRIVE_MASTER
	call divide_open_drive_asm
	; returns block device in hl
	
	push hl
	ld hl,msg_opening_filesystem
	call asciiprint_print
	call asciiprint_newline
	pop hl

	ld ix,current_filesystem
	call fatfs_fsopen_asmentry

	ld hl,msg_opening_directory
	call asciiprint_print
	call asciiprint_newline

	ld hl,current_filesystem
	ld de,current_dir
	call open_root_dir_asmentry

	ld hl,msg_ok
	call asciiprint_print

	; wait for space
.wait_space
	ld bc,0x7ffe
	in a,(c)
	and 1
	jr nz,wait_space

	ret

.msg_initialising
	defm "Initialising..."
	defb 0

.msg_opening_drive
	defm "Opening drive..."
	defb 0

.msg_opening_filesystem
	defm "Opening filesystem..."
	defb 0

.msg_opening_directory
	defm "Opening directory..."
	defb 0

.msg_ok
	defm "All OK. Press space"
	defb 0
