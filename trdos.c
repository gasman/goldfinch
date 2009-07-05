#include <stdio.h>
#include <strings.h>
#include "include/divide.h"
#include "include/block_device.h"
#include "include/trdos.h"
#include "include/dirent.h"

int main() {
	unsigned char buffer[256];
	BLOCK_DEVICE *device;
	TRDOS_FILESYSTEM trdos_fs;
	TRDOS_DIR dir;
	struct dirent entry;
	TRDOS_FILE file;
	ssize_t read_count;

	/* Open the block device for the DivIDE master drive */
	device = divide_open_drive(DIVIDE_DRIVE_MASTER);
	/* open the tr-dos filesystem on it */
	trdos_fsopen(device, &trdos_fs);
	
	trdos_opendir(&trdos_fs, &dir);
	while(trdos_readdir(&trdos_fs, &dir, &entry)) {
		printf("%s\n", entry.d_name);
		if (strcmp(entry.d_name, "file_id t") == 0) {
			printf("- found file_id.t!\n");
			trdos_open_dirent(&trdos_fs, &entry, &file);
			read_count = trdos_read(&trdos_fs, &file, buffer, 200);
			printf("- read %d bytes from file_id.t\n", read_count);
			buffer[200] = '\0';
			printf("bytes are:\n%s\n", buffer);
		}
	}

	printf("done.\n");
	return 0;
}
