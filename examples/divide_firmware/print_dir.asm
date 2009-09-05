XLIB print_dir

LIB current_dir
LIB current_dirent

LIB dir_home
LIB read_dir_asmentry
LIB clear_screen
LIB asciiprint_setpos
LIB asciiprint_print
LIB asciiprint_newline
LIB asciiprint_putchar

include "../../libsrc/lowio/lowio.def"

; Print up to 24 rows of the current directory, starting from the 'BC'th entry to the BC+23rd
.print_dir
	push bc

	; clear screen and set print pos to top
	call clear_screen
	ld bc,0
	call asciiprint_setpos
	
	; rewind to start of current dir
	ld hl,current_dir
	call dir_home

	; skip past BC entries
.skip_loop
	pop bc
	ld a,b
	or c
	jr z,skip_done
	push bc
	ld iy,current_dir
	ld de,current_dirent
	call read_dir_asmentry
	jr skip_loop
.skip_done
	
.dir_loop
	ld b,24 ; print a maximum of 24 entries
.print_entry
	ld iy,current_dir
	ld de,current_dirent
	push bc
	call read_dir_asmentry
	pop bc
	; if 0 returned, end of dir
	ld a,h
	or l
	ret z
	
	push bc
	ld hl,current_dirent + dirent_filename
	push hl
	call asciiprint_print
	pop hl
	; indicate directory with a *
	ld a,(current_dirent + dirent_flags)
	and 0x01
	jr z,not_dir
	ld a,'*'
	call asciiprint_putchar
.not_dir
	call asciiprint_newline
	pop bc
	djnz print_entry

	ret
	
.end_of_dir
	pop bc
	ret