XLIB firmware_data

XDEF current_filesystem
XDEF current_dir
XDEF current_dirent

XDEF dir_page_start
XDEF dir_this_page_count
XDEf dir_has_next_page
XDEF dir_selected_entry

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
