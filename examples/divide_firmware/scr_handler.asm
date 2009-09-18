XLIB scr_handler
XDEF scr_handler_test
XDEF scr_handler_run

LIB current_dirent
LIB open_dirent_asmentry
LIB read_file_asmentry
LIB close_file
LIB keyscan_wait_key
LIB nmi_show_new_page
LIB check_file_extension

include "../../libsrc/lowio/lowio.def"

.scr_handler

; return carry set if this is a .scr file
.scr_handler_test
	; find file extension - the char after the last dot before the terminating null
	ld hl,current_dirent + dirent_filename
	ld de,string_scr
	jp check_file_extension
	
.string_scr
	defm "SCR"
	defb 0

.scr_handler_run
	ld ix,current_dirent
	ld c,1 ; read access
	call open_dirent_asmentry
	; returns file handle in hl
	push hl
	pop ix
	push hl
	; read 6912 bytes to screen
	ld de,0x4000
	ld bc,0x1b00
	call read_file_asmentry
	pop hl
	call close_file
	
	; wait for a key
	call keyscan_wait_key
	jp nmi_show_new_page