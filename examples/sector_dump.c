#include <stdio.h>
#include "../include/divide.h"
#include "../include/block_device.h"
#include "../include/buffer.h"

int main() {
	unsigned char *buffer;
	unsigned int x,y;
	BLOCK_DEVICE *device;
	
	buffer_emptybuffers();

	/* Open the block device for the DivIDE master drive */
	device = divide_open_drive(DIVIDE_DRIVE_MASTER);
	printf("Handle to divide device: %04x\n", device);
	
	/* Read block number 0 from it */
	buffer = buffer_findbuf(device, 0L);

	/* lower-level ways of doing the same thing: */
	/* read_block(device, (void *)buffer, 0L); */
	/* divide_read_sector((void *)buffer, 0L, DIVIDE_DRIVE_MASTER); */

	printf("Sector dump from %04x:\n", buffer);
	
	for (y = 0; y < 256; y += 16) {
		for (x = 0; x < 16; x++) {
			printf("%02x ", buffer[y|x]);
		}
		printf("\n");
	}
	
	/* to test writing a block:
	buffer[0] = 0;
	write_block(device, (void *)buffer, 1L); */

	buffer = buffer_findbuf(device, 0L);
	printf("Buffer re-found at %04x:\n", buffer);

	buffer = buffer_findbuf(device, 1L);
	printf("Other buffer allocated at %04x:\n", buffer);

	for (y = 0; y < 256; y += 16) {
		for (x = 0; x < 16; x++) {
			printf("%02x ", buffer[y|x]);
		}
		printf("\n");
	}

	printf("done.\n");
	return 0;
}
