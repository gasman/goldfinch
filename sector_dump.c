#include <stdio.h>
#include "include/divide.h"
#include "include/block_device.h"

int main() {
	unsigned char buffer[512];
	unsigned int x,y;
	BLOCK_DEVICE *device;

	printf("Sector dump:\n");
	
	/* Open the block device for the DivIDE master drive */
	device = divide_open_drive(DIVIDE_DRIVE_MASTER);
	/* Read block number 0 from it */
	read_block(device, (void *)buffer, 0L);
	/* lower-level way of doing the same thing */
	/* divide_read_sector((void *)buffer, 0L, DIVIDE_DRIVE_MASTER); */

	for (y = 0; y < 256; y += 16) {
		for (x = 0; x < 16; x++) {
			printf("%02x ", buffer[y|x]);
		}
		printf("\n");
	}

	printf("done.\n");
	return 0;
}
