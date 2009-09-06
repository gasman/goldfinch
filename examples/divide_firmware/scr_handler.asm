XLIB scr_handler
XDEF scr_handler_test
XDEF scr_handler_run

LIB current_dirent
LIB open_dirent_asmentry
LIB read_file_asmentry
LIB close_file
LIB keyscan_key
LIB nmi_show_new_page

include "../../libsrc/lowio/lowio.def"

.scr_handler

; return carry set if this is a .scr file
.scr_handler_test

	; find file extension - the char after the last dot before the terminating null
	ld hl,current_dirent + dirent_filename
.save_extension_pos
	ld d,h
	ld e,l
.check_char
	ld a,(hl)
	or a
	jr z,end_of_filename
	cp '.'
	inc hl
	jr z,save_extension_pos	; if it was a dot, record the next address (now in HL) in de
	jr check_char
.end_of_filename	; extension is now in DE - compare it against 'SCR'
	ld hl,string_scr
.compare
	ld a,(de)
	cp (hl)
	jr nz,match_failed
	or a	; end comparison (with success) if A=0
	inc hl
	inc de
	jr nz,compare
	scf
	ret
.match_failed
	or a	; reset carry flag
	ret
	
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
.wait_key
	halt
	ld a,(keyscan_key)
	or a
	jr z,wait_key
	jp nmi_show_new_page