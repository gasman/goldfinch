; int trdos_read_file(FILE *file, void *buf, unsigned int nbyte)

XLIB trdos_read_file_callee

LIB trdos_read_file

.trdos_read_file_callee
	pop hl
	pop bc
	pop de
	pop ix
	push hl
	; enter with: IX = file, DE = buf, BC = nbyte
	; returns hl=0 and carry reset if end of file
	jp trdos_read_file
