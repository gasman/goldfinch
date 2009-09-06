; Handler for non-maskable interrupts (aka The Magic Button)
XLIB nmi

LIB print_dir
LIB keyscan_key

LIB dir_selected_entry
LIB dir_page_start
LIB dir_this_page_count
LIB dir_has_next_page

.nmi
	; save screen
	ld a,1
	out (0xe3),a	; page in DivIDE RAM page 1
	ld hl,0x4000
	ld de,0x2000
	ld bc,0x1b00
	ldir
	
	xor a
	out (0xe3),a	; page in DivIDE RAM page 0 at 0x2000..0x3fff
	
	ei
	
.show_new_page
	ld bc,(dir_page_start)	; print directory listing starting from dir_page_start
	call print_dir
	; TODO: some appropriate behaviour if dir is entirely empty (dir_this_page_count = 0)
	
	ld a,(dir_selected_entry)
	ld c,0x78	; add highlight
	call paint_row
	
	; wait for key
.wait_key
	halt
	ld a,(keyscan_key)
	cp ' '
	jr z,key_space
	cp 'q'
	jr z,key_up
	cp 'a'
	jr z,key_down
	jr wait_key
	
.key_up
	ld a,(dir_selected_entry)	; are we on the first entry?
	or a
	jr z,prev_page	; if so, need to go up to previous page (if that's possible)
	ld c,0x38	; remove highlight
	call paint_row
	dec a
	ld (dir_selected_entry),a
	ld c,0x78	; add highlight
	call paint_row
	jr wait_key

.key_down
	ld a,(dir_selected_entry)	; are we on the last entry?
	ld hl,dir_this_page_count
	inc a
	cp (hl)
	dec a
	jr nc,next_page	; if so, need to go down to next page (if that's possible)
	ld c,0x38	; remove highlight
	call paint_row
	inc a
	ld (dir_selected_entry),a
	ld c,0x78	; add highlight
	call paint_row
	jr wait_key
	
.key_space
	; restore screen
	di	; don't let interrupt routine write to RAM (because this will overwrite the screen)
	ld a,1
	out (0xe3),a
	ld hl,0x2000
	ld de,0x4000
	ld bc,0x1b00
	ldir
	ret

.prev_page
	; are we on the first screen?
	ld hl,(dir_page_start)
	ld a,h
	or l
	jr z,wait_key	; if so, ignore keypress
	ld bc,0x10000 - 24
	add hl,bc	; reduce dir_page_start by 24
	ld (dir_page_start),hl
	ld a,23	; move to the last entry on the page
	ld (dir_selected_entry),a
	jr show_new_page

.next_page
	ld a,(dir_has_next_page)	; is this the last page?
	or a
	jr z,wait_key	; if so, ignore keypress
	ld hl,(dir_page_start)
	ld bc,24
	add hl,bc	; add 24 to dir_page_start
	ld (dir_page_start),hl
	xor a	; move to the last entry on the page
	ld (dir_selected_entry),a
	jp show_new_page

; enter with a = char row to paint, c = attribute to paint with
; preserves A and C, corrupts B and HL
.paint_row
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl
	ld h,0x16	; shifts left to become 0x5800
	add hl,hl
	add hl,hl
	ld b,0x20
.paint_row_lp
	ld (hl),c
	inc hl
	djnz paint_row_lp
	ret
