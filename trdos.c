#include <stdio.h>
#include <strings.h>
#include "include/divide.h"
#include "include/block_device.h"
#include "include/trdos.h"
#include "include/lowio.h"
#include "include/buffer.h"

int main() {
	unsigned char buffer[256];
	BLOCK_DEVICE *device;
	FILESYSTEM fs;
	DIR dir;
	DIRENT entry;
	unsigned char i;
	
	buffer_emptybuffers();

	/* Open the block device for the DivIDE master drive */
	device = divide_open_drive(DIVIDE_DRIVE_MASTER);
	/* open the tr-dos filesystem on it */
	trdos_fsopen(device, &fs);

	open_root_dir(&fs, &dir);
	while (trdos_read_dir(&dir, &entry)) {
		printf("%s\n", entry.filename);
	}

	printf("done... trdos dir entry read at %04x\n", &entry);
	return 0;
}
