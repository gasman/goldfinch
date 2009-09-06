XLIB dir_handler
XDEF dir_handler_test
XDEF dir_handler_run

LIB current_dirent
LIB current_dir
LIB dir_page_start
LIB dir_selected_entry

LIB open_subdir_asmentry
LIB nmi_show_new_page

include "../../libsrc/lowio/lowio.def"

.dir_handler
; return carry set if current_dirent is a dir
.dir_handler_test
	ld a,(current_dirent + dirent_flags)
	rra	; move bit 0 (directory bit) into carry
	ret
.dir_handler_run
	ld iy,current_dirent
	ld de,current_dir
	call open_subdir_asmentry
	; reset directory position to top
	ld hl,0
	ld (dir_page_start),hl
	xor a
	ld (dir_selected_entry),a
	jp nmi_show_new_page
