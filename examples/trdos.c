#include <stdio.h>
#include <strings.h>
#include "../include/divide.h"
#include "../include/block_device.h"
#include "../include/trdos.h"
#include "../include/lowio.h"
#include "../include/buffer.h"

int main() {
	unsigned char buffer[256];
	BLOCK_DEVICE *device;
	FILESYSTEM fs;
	DIR dir;
	DIRENT entry;
	unsigned char i;
	FSFILE *file;
	
	/* avoid issues with the interrupt routine hijacking the IY register -
	not sure how big a problem this really is, but can't hurt... */
	#asm
	di
	#endasm

	buffer_emptybuffers();

	/* Open the block device for the DivIDE master drive */
	device = divide_open_drive(DIVIDE_DRIVE_MASTER);
	/* open the tr-dos filesystem on it */
	trdos_fsopen(device, &fs);

	open_root_dir(&fs, &dir);
	for (i = 0; i < 4; i++) {
		read_dir(&dir, &entry);
		printf("%s\n", entry.filename);
	}
	file = open_dirent(&entry, FILE_MODE_EXC_READ);
	read_file(file, buffer, 200);
	close_file(file);

	printf("block device at %04x\n", device);
	printf("trdos filesystem at %04x\n", &fs);
	printf("trdos dir at %04x\n", &dir);
	printf("trdos dir entry populated at %04x\n", &entry);
	printf("done... trdos dir entry opened at %04x\n", file);
	printf("first 200 chars stored at %04x\n", buffer);

	#asm
	ei
	#endasm

	return 0;
}
