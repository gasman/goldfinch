XLIB trdos_close_file

include "../lowio/lowio.def"

.trdos_close_file
	; indicate file as closed by nullifying fs driver pointer
	xor a
	ld (iy + filesystem_driver),a
	ld (iy + filesystem_driver + 1),a
	scf
	ret
