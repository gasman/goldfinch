XLIB tap_handler
XDEF tap_handler_test
XDEF tap_handler_run

LIB current_tap_file
LIB current_dirent
LIB open_dirent_asmentry
LIB close_file
LIB nmi_exit
LIB check_file_extension

include "../../libsrc/lowio/lowio.def"

.tap_handler

; return carry set if this is a .tap file
.tap_handler_test
	; find file extension - the char after the last dot before the terminating null
	ld hl,current_dirent + dirent_filename
	ld de,string_tap
	jp check_file_extension
	
.string_tap
	defm "TAP"
	defb 0

.tap_handler_run
	; if we already have a tap file open, close it
	ld hl,(current_tap_file)
	ld a,h
	or l
	call nz,close_file
	
	ld ix,current_dirent
	ld c,1 ; read access
	call open_dirent_asmentry
	; returns file handle in hl
	ld (current_tap_file),hl

	jp nmi_exit	; return to Spectrum OS
