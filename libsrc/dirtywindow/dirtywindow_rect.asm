XLIB dirtywindow_rect

LIB asciiprint_calcpos

; Clear a rectangular space on screen, with a pixel border around it
; enter with BC = Y/X pos of top left corner, DE = height/width
.dirtywindow_rect
	push bc
.draw_char_line
	push bc
	call asciiprint_calcpos	; now BC = screen address
	ld h,b
	ld l,c	; now HL = screen address
	ld c,8
.draw_pix_line
	push hl
	
	ld b,e
	ld a,0x80
	
.draw_byte
	ld (hl),a
	inc l
	xor a
	djnz draw_byte
	; go back one byte to draw right border
	dec l
	set 0,(hl)
	
	pop hl
	inc h	; next pixel line
	dec c
	jr nz,draw_pix_line
	pop bc
	inc b
	dec d
	jr nz,draw_char_line
	
	dec h	; now hl is back at the last pixel line, so we can draw the bottom border
	ld b,e
.draw_bottom_line_byte
	ld (hl),0xff
	inc l
	djnz draw_bottom_line_byte
	
	pop bc	; return to top, to draw top border
	call asciiprint_calcpos	; now bc = screen address
	ld h,b
	ld l,c
	ld b,e
.draw_top_line_byte
	ld (hl),0xff
	inc l
	djnz draw_top_line_byte

	ret
	