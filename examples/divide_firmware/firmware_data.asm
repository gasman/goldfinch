XLIB firmware_data

XDEF current_filesystem
XDEF current_dir
XDEF current_dirent

include "../../libsrc/lowio/lowio.def"

.firmware_data

.current_filesystem
	defs filesystem_size
.current_dir
	defs dir_size
.current_dirent
	defs dirent_size
