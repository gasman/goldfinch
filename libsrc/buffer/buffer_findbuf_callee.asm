; void *buffer_findbuf_callee(BLOCK_DEVICE *block_device, unsigned long block_number)

XLIB buffer_findbuf_callee

LIB buffer_findbuf

.buffer_findbuf_callee
	pop ix	; get return address
	pop de
	pop bc	; get block number
	ex (sp),ix	; get device and restore return address
	jp buffer_findbuf
