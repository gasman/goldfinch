; extern void __LIB__ read_block(BLOCK_DEVICE *, void *, unsigned long block_number);

XLIB read_block

.read_block
; initially stack contains: return address, block_number lo, block_number hi, buffer, block_device

	; get BLOCK_DEVICE pointer into hl
	ld ix,0
	add ix,sp
	ld l,(ix+8)
	ld h,(ix+9)
	
	; get BLOCK_DEVICE_DRIVER pointer into hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	
	; get read_block function pointer into hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	
	; now call it (using CALLER linkage) with the same method signature that we were called with
	jp (hl)
