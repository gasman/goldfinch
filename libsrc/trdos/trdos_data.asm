; Global data area for trdos library

XLIB trdos_data

XDEF file_handles
XDEF trdos_data_end

include	"../lowio/lowio.def"
include	"trdos.def"

.trdos_data
.file_handles	defs	file_trdos_size*file_numhandles ; file handles
.fatfs_data_end
