XLIB open_tap_for_writing

LIB dirtywindow_rect
LIB asciiprint_print
LIB asciiprint_setpos
LIB nmi_show_new_page
LIB input_string
LIB input_filename

LIB current_dir
LIB create_file_asmentry
LIB write_file_asmentry
LIB close_file

LIB current_write_tap_file

include "../../libsrc/fatfs/fatfs.def"	; for fm_exc_write

.open_tap_for_writing
	ld bc,0x0804
	ld de,0x0818
	call dirtywindow_rect
	ld bc,0x0905
	call asciiprint_setpos
	ld hl,prompt
	call asciiprint_print
	ld bc,0x0b05
	ld hl,input_filename
	call input_string
	; exit if input cancelled (carry reset)
	jp nc,nmi_show_new_page
	
	; close the open file, if any
	ld hl,(current_write_tap_file)
	ld a,h
	or l
	call nz,close_file
	
	; create file
	ld iy,current_dir
	ld hl,input_filename
	ld c,fm_exc_write
	call create_file_asmentry	; returns with file handle in hl
	ld (current_write_tap_file),hl
	
	jp nmi_show_new_page

.prompt
	defm "new TAP filename:"
	defb 0