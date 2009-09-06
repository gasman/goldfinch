XLIB keyscan_table_capsshift

.keyscan_table_capsshift
	defb 0	; no key
	; codes for B=0xfe
	defb 0, 'Z', 'X', 'C', 'V'
	; codes for B=0xfd
	defb 'A', 'S', 'D', 'F', 'G'
	; codes for B=0xfb
	defb 'Q', 'W', 'E', 'R', 'T'
	; codes for B=0xf7
	defb 0, 0, 0, 0, 0x08	; shifted 1/2/3/4/5 (5 = left cursor)
	; codes for B=0xef
	defb 0x0c, 0, 0x09, 0x0b, 0x0a	; shifted 0/9/8/7/6 (0 = delete, 8 = right, 7 = up, 6 = down)
	; codes for B=0xdf
	defb 'P', 'O', 'I', 'U', 'Y'
	; codes for B=0xbf
	defb 0x0d, 'L', 'K', 'J', 'H'
	; codes for B=0x7f
	defb 0x1b, 0, 'M', 'N', 'B'	; 0x1b = chosen for BREAK to match 'escape' in ASCII