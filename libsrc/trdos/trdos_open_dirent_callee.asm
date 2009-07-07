; void __CALLEE__ trdos_open_dirent_callee(TRDOS_FILESYSTEM *fs, DIRENT *dirent, TRDOS_FILE *file)
; open a TRDOS_FILE from a dirent record

XLIB trdos_open_dirent_callee
XDEF ASMDISP_TRDOS_OPEN_DIRENT_CALLEE

include	"trdos.def"

.trdos_open_dirent_callee

	pop hl
	pop ix
	pop iy
	pop de
	push hl

   ; enter : iy = DIRENT *dirent
   ;         ix = TRDOS_FILE *file
   ;         (TRDOS_FILESYSTEM *fs is not currently used)
   ; uses  : af, hl, ix, iy
   
.asmentry
	; file->block_number = (dirent->start_track << 4) | dirent->start_sector;
	ld h,0
	; two high bytes will always be 0
	ld (ix + trd_file_block_number + 2),h
	ld (ix + trd_file_block_number + 3),h

	; also reset blocks_read to 0
	ld (ix + trd_file_blocks_read + 3),h
	
	ld l,(iy + trd_dirent_start_track)
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld a,(iy + trd_dirent_start_sector)
	or l
	ld (ix + trd_file_block_number),a
	ld (ix + trd_file_block_number + 1),h
	
	ld a,(iy + trd_dirent_sector_count)
	ld (ix + trd_file_block_count),a
	
	; set file->pos to 256 past block_buffer, to ensure that the first call to read will immediately fetch the first sector
	push ix
	pop hl
	ld de,trd_file_block_buffer + 256
	add hl,de
	ld (ix + trd_file_pos),l
	ld (ix + trd_file_pos + 1),h
	
	ret

DEFC ASMDISP_TRDOS_OPEN_DIRENT_CALLEE = asmentry - trdos_open_dirent_callee
