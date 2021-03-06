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

LIB dir_this_page_count
LIB dir_has_next_page

include "../../libsrc/lowio/lowio.def"

; Print up to 24 rows of the current directory, starting from the 'BC'th entry to the BC+23rd
; Sets dir_this_page_count and dir_has_next_page
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
	dec bc
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
	jr z,end_of_dir
	
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

	; test whether next entry is end of dir (so we know whether to allow paging down)
	ld iy,current_dir
	ld de,current_dirent
	call read_dir_asmentry
	ld a,h
	or l
	ld (dir_has_next_page),a
	ld a,24
	ld (dir_this_page_count),a
	ret
	
.end_of_dir
	ld a,24
	sub b
	ld (dir_this_page_count),a
	xor a
	ld (dir_has_next_page),a
	ret