#include <stdio.h>
#include "include/divide.h"
#include "include/block_device.h"
#include "include/trdos.h"
#include "include/dirent.h"

int main() {
	unsigned char buffer[512];
	unsigned int x,y;
	BLOCK_DEVICE *device;
	TRDOS_FILESYSTEM trdos_fs;
	TRDOS_DIR dir;
	struct dirent entry;

	/* Open the block device for the DivIDE master drive */
	device = divide_open_drive(DIVIDE_DRIVE_MASTER);
	/* open the tr-dos filesystem on it */
	trdos_fsopen(device, &trdos_fs);
	
	trdos_opendir(&trdos_fs, &dir);
	while(trdos_readdir(&trdos_fs, &dir, &entry)) {
		printf("%s\n", entry.d_name);
	}

	printf("done.\n");
	return 0;
}
