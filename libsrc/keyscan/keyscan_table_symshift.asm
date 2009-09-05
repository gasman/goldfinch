XLIB keyscan_table_symshift

.keyscan_table_symshift
	defb 0	; no key
	; codes for B=0xfe
	defb 0, ':', '`', '?', '/'
	; codes for B=0xfd
	defb '~', '|', '\', '{', '}'
	; codes for B=0xfb
	defb 0, 0, 0, '<', '>'
	; codes for B=0xf7
	defb '!', '@', '#', '$', '%'
	; codes for B=0xef
	defb '_', ')', '(', 0x27, '&'	; 0x27 = apostrophe
	; codes for B=0xdf
	defb '"', ';', 0, ']', '['
	; codes for B=0xbf
	defb 0x0d, '=', '+', '-', '^'
	; codes for B=0x7f
	defb ' ', 0, '.', ',', '*'