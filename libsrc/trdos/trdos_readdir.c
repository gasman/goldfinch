#include "../../include/trdos.h"
#include "../../include/block_device.h"

#include <string.h>

int trdos_readdir(TRDOS_FILESYSTEM *fs, TRDOS_DIR *dir, DIRENT *dirent) {
	if (*(dir->current_dir_entry) == 0) {
		return 0; /* end of dir */
	} else {
		memcpy(dirent->d_name, dir->current_dir_entry, 9);
		dirent->d_name[9] = '\0';
		dirent->sector_count = dir->current_dir_entry[13];
		dirent->start_sector = dir->current_dir_entry[14];
		dirent->start_track = dir->current_dir_entry[15];
		
		dir->current_dir_entry += 16;
		if (dir->current_dir_entry == dir->block_buffer + 256) {
			/* read next sector of directory */
			dir->block_number += 1;
			read_block(fs->block_device, dir->block_buffer, dir->block_number);
			dir->current_dir_entry = dir->block_buffer;
		}
	}
}
