#include "../../include/trdos.h"
#include "../../include/block_device.h"

void trdos_opendir(TRDOS_FILESYSTEM *fs, TRDOS_DIR *dir) {
	dir->block_number = 0;
	dir->current_dir_entry = dir->block_buffer;
	read_block(fs->block_device, dir->block_buffer, dir->block_number);
}
