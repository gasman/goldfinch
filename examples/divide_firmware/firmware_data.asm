XLIB firmware_data

XDEF current_filesystem
XDEF current_dir
XDEF current_dirent

XDEF dir_page_start
XDEF dir_this_page_count
XDEF dir_has_next_page
XDEF dir_selected_entry

XDEF input_filename

XDEF current_tap_file

XDEF firmware_is_active

XDEF reg_store_iff
XDEF reg_store_im
XDEF reg_store_r
XDEF reg_store_i
XDEF reg_store_sp
XDEF reg_store_main
XDEF reg_store_end

XDEF nmi_final_ret

include "../../libsrc/lowio/lowio.def"

.firmware_data

.current_filesystem
	defs filesystem_size
.current_dir
	defs dir_size
.current_dirent
	defs dirent_size

.dir_page_start
	defw 0	; index number of first directory entry on the current page
.dir_this_page_count
	defb 0	; number of directory entries shown on this page
.dir_has_next_page
	defb 0	; zero if this is the last page
.dir_selected_entry
	defb 0	; index number of highlighted directory entry, relative to dir_page_start

.input_filename
	defs 0x20	; buffer to contain filename input at prompt

.current_tap_file
	defw 0	; address of currently open TAP file handle

.firmware_is_active
	defb 0	; will be 0x42 if active (indicating that we should not reinitialize file handles on reset)
	
; storage space for registers during NMI
.reg_store_iff
	defb 0	; 0x3658 in fatware; 1 if interrupts enabled
.reg_store_im
	defb 0	; 0x3659 in fatware; 0 if IM0/1, 1 if IM2
.reg_store_r
	defb 0	; 0x365a in fatware
.reg_store_i
	defb 0	; 0x365b in fatware
.reg_store_sp
	defw 0	; 0x365c in fatware
; other registers
.reg_store_main
	defw 0	; iy => 0x365e in fatware
	defw 0	; ix => 0x3660
	defw 0	; hl'
	defw 0	; de'
	defw 0	; bc'
	defw 0	; af'
	defw 0	; hl
	defw 0	; de
	defw 0	; bc
	defw 0	; af
.reg_store_end

; a dynamically-modified JP instruction to exit_ei_ret or exit_ret,
; used to exit the nmi routine
.nmi_final_ret
	defs 3
