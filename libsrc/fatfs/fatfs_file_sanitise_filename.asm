XLIB fatfs_file_sanitise_filename
	; Enter with HL = pointer to filename; sanitise it so that it's a valid filename
	; for creation with fatfs_create_file.
	; Currently just upcases the filename.
	; TODO: other sanity checks such as length
.fatfs_file_sanitise_filename
.upcase
	ld a,(hl)
	or a
	ret z
	cp 'a'
	jr c,not_alpha	; chars below 'a' don't need capitalising
	cp 'z'+1
	jr nc,not_alpha	; chars above 'z' don't need capitalising
	res 5,(hl)	; reset bit 5 to capitalise
.not_alpha
	inc hl
	jr upcase
