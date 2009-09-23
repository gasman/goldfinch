XLIB save_scr

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

include "../../libsrc/fatfs/fatfs.def"	; for fm_exc_write

.save_scr
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
	
	; restore screen
	di	; don't let interrupt routine write to RAM (because this will overwrite the screen)
	ld a,1
	out (0xe3),a
	ld hl,0x2000
	ld de,0x4000
	ld bc,0x1b00
	ldir
	; page DivIDE page 0 back in
	xor a
	out (0xe3),a	; page in DivIDE RAM page 0 at 0x2000..0x3fff
	ei
	
	; create file
	ld iy,current_dir
	ld hl,input_filename
	ld c,fm_exc_write
	call create_file_asmentry	; returns with file handle in hl
	
	push hl
	
	; write file
	push hl
	pop iy
	ld hl,0x4000
	ld de,0x1b00
	call write_file_asmentry
	
	; close file
	pop hl
	call close_file
	
	jp nmi_show_new_page

.prompt
	defm "Save screen as:"
	defb 0