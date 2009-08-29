LIB buffer_emptybuffers
LIB divide_open_drive
XREF divide_open_drive_asm
LIB fatfs_init
LIB fatfs_fsopen_callee
XREF fatfs_fsopen_asmentry
LIB open_root_dir_callee
XREF open_root_dire_asmentry
LIB read_dir_callee
XREF read_dir_asmentry
LIB open_dirent_callee
XREF open_dirent_asmentry
LIB read_file_callee
XREF read_file_asmentry
LIB close_file
LIB open_subdir_callee
XREF open_subdir_asmentry
LIB dir_home

include "../../libsrc/divide/divide.def"
include "../../libsrc/block_device/block_device.def"
include "../../libsrc/lowio/lowio.def"

	org 0x8000
	
	di

	call buffer_emptybuffers
	call fatfs_init
	
	ld a,DIVIDE_DRIVE_MASTER
	call divide_open_drive_asm + divide_open_drive - divide_open_drive
	; returns block device in hl

	ld ix,filesystem
	call fatfs_fsopen_asmentry + fatfs_fsopen_callee - fatfs_fsopen_callee

.list_root_dir
	ld hl,filesystem
	ld de,dir
	call open_root_dir_asmentry + open_root_dir_callee - open_root_dir_callee
	
.list_current_dir
	ld iy,0x5c3a
	call 3435 ; cls
	; set up text printing
	xor a
	ld (0x5c3c),a
	
	ld b,21 ; print a maximum of 21 entries
.print_entry
	ld iy,dir
	ld de,dirent
	push bc
	call read_dir_asmentry + read_dir_callee - read_dir_callee
	; if 0 returned, end of dir
	ld a,h
	or l
	jr z,printed_all
	
	ld hl,dirent + dirent_filename
.print_filename
	ld a,(hl)
	or a
	jr z,print_filename_done
	push hl
	ld iy,0x5c3a
	rst 0x10
	pop hl
	inc hl
	jr print_filename

.print_filename_done
	; indicate directory with a *
	ld a,(dirent + dirent_flags)
	and 0x01
	jr z,not_dir
	ld a,'*'
	rst 0x10
.not_dir

	ld a,0x0d
	rst 0x10
	pop bc
	djnz print_entry

.printed_all

; menu chooser
	xor a
	ld (selected_index),a
	call show_bar

.menu_loop
	; check for Q key
	ld bc,0xfbfe
	in a,(c)
	and 1
	jr z,key_q
	; check for A key
	ld bc,0xfdfe
	in a,(c)
	and 1
	jr z,key_a
	; check for space key
	ld bc,0x7ffe
	in a,(c)
	and 1
	jr z,key_space
	jr menu_loop
	
.key_q
	ld a,(selected_index)
	or a
	jr z,menu_loop	; cannot go above 0
	call hide_bar
	ld hl,selected_index
	dec (hl)
	ld a,(hl)
	call show_bar
	call wait_nokey
	jr menu_loop

.key_a
	ld a,(selected_index)
	cp 22
	jr nc,menu_loop	; cannot go above 21
	call hide_bar
	ld hl,selected_index
	inc (hl)
	ld a,(hl)
	call show_bar
	call wait_nokey
	jr menu_loop
	
.key_space
	call wait_nokey
	
; rewind the dir, and fastforward to the 'selected_index'th entry
	ld hl,dir
	call dir_home
	ld a,(selected_index)
	ld b,a
	inc b
.ffwd_dir
	push bc
	ld iy,dir
	ld de,dirent
	call read_dir_asmentry + read_dir_callee - read_dir_callee
	pop bc
	djnz ffwd_dir
	
	; if this is a directory, open it as a directory and return to list_current_dir
	ld a,(dirent + dirent_flags)
	bit 0,a
	jr z,dirent_is_file
	; dirent is a dir
	ld iy,dirent
	ld de,dir
	call open_subdir_asmentry + open_subdir_callee - open_subdir_callee
	jp list_current_dir
	
.dirent_is_file
	ld ix,dirent
	ld c,1 ; read access
	call open_dirent_asmentry + open_dirent_callee - open_dirent_callee
	; returns file handle in hl
	push hl
	pop ix
	push hl
	; read 6912 bytes to screen
	ld de,0x4000
	ld bc,0x1b00
	call read_file_asmentry + read_file_callee - read_file_callee
	pop hl
	call close_file
	
	; wait for a key
.wait_key
	ld bc,0x00fe
	in a,(c)
	cpl
	and 0x1f
	jr z,wait_key
	
	jp list_root_dir
	
.wait_nokey	; wait until none of Q, A, space are pressed
	ld bc,0x79fe
	in a,(c)
	and 1
	jr z,wait_nokey
	ret

.selected_index
	defb 0
	
.show_bar
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl
	ld h,0x16	; shifts left to become 0x5800
	add hl,hl
	add hl,hl
	ld (hl),0x78
	ld d,h
	ld e,l
	inc e
	ld bc,31
	ldir
	ret
.hide_bar
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl
	ld h,0x16	; shifts left to become 0x5800
	add hl,hl
	add hl,hl
	ld (hl),0x38
	ld d,h
	ld e,l
	inc e
	ld bc,31
	ldir
	ret
	
.filesystem
	defs filesystem_size
.dir
	defs dir_size
.dirent
	defs dirent_size
