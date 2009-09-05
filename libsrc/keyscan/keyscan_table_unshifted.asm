XLIB keyscan_table_unshifted

.keyscan_table_unshifted
	defb 0	; no key
	; codes for B=0xfe
	defb 0, 'z', 'x', 'c', 'v'
	; codes for B=0xfd
	defb 'a', 's', 'd', 'f', 'g'
	; codes for B=0xfb
	defb 'q', 'w', 'e', 'r', 't'
	; codes for B=0xf7
	defb '1', '2', '3', '4', '5'
	; codes for B=0xef
	defb '0', '9', '8', '7', '6'
	; codes for B=0xdf
	defb 'p', 'o', 'i', 'u', 'y'
	; codes for B=0xbf
	defb 0x0d, 'l', 'k', 'j', 'h'
	; codes for B=0x7f
	defb ' ', 0, 'm', 'n', 'b'