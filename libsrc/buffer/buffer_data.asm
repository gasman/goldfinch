; Global data area for buffer library

XLIB buffer_data
XDEF buf_mrulist
XDEF buf_handles
XDEF buf_buffers

include "buffer.def"

.buffer_data

.buf_mrulist	defs	buf_numbufs		; IDs of buffers in order, MRU first
.buf_handles	defs	fbh_size*buf_numbufs	; buffer handles
.buf_buffers	defs	buf_secsize*buf_numbufs	; sector buffers
