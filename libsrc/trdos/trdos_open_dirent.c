#include "../../include/trdos.h"

void trdos_open_dirent(TRDOS_FILESYSTEM *fs, DIRENT *dirent, TRDOS_FILE *file) {
	file->block_number = (dirent->start_track << 4) | dirent->start_sector;
	file->blocks_read = 0;
	file->block_count = dirent->sector_count;
	file->pos = file->block_buffer + 256; /* ensures that the first call to read will immediately fetch the first sector */
}
