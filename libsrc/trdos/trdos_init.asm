XLIB trdos_init

LIB trdos_data
LIB trdos_data_end

.trdos_init
	; clear trdos data area
	ld hl,trdos_data
	ld de,trdos_data + 1
	ld bc,trdos_data_end - trdos_data - 1
	ld (hl),0
	ldir
	ret
