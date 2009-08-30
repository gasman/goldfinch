#include <stdio.h>

#include "../include/fatfs.h"
#include "../include/divide.h"
#include "../include/buffer.h"

FILESYSTEM fs;
DIR dir;
DIRENT entry;
unsigned char buffer[256];

int main() {
	BLOCK_DEVICE *device;
	FSFILE *file;
	unsigned char i;
	
	char *stringtowrite = "i am a fish.";
	char *newfilename = "new2.txt";
	char *string2 = "i am still a fish.";
	
	/* avoid issues with the interrupt routine hijacking the IY register -
	not sure how big a problem this really is, but can't hurt... */
	#asm
	di
	#endasm
	
	buffer_emptybuffers(); // TODO: Can this be sensibly incorporated into fatfs_init?

	printf("Initializing fatfs library\n");
	fatfs_init();
	printf("opening DivIDE master drive\n");
	device = divide_open_drive(DIVIDE_DRIVE_MASTER);
	printf("opening FATfs filesystem on it\n");
	fatfs_fsopen(device, &fs);
	printf("fatfs filesystem at %04x\n", &fs);
	open_root_dir(&fs, &dir);
	printf("dir handle at %04x\n", &dir);
	for (i = 0; i < 4; i++) {
		read_dir(&dir, &entry);
		printf("%s\n", entry.filename);
	}
	printf("dirent at %04x\n", &entry);
	file = open_dirent(&entry, FILE_MODE_EXC_WRITE);
	printf("file handle at %04x\n", file);
	write_file(file, stringtowrite, 12);
	write_file(file, stringtowrite, 12);
	write_file(file, stringtowrite, 12);
	write_file(file, stringtowrite, 12);
	write_file(file, stringtowrite, 12);
	write_file(file, stringtowrite, 12);
	write_file(file, stringtowrite, 12);
	write_file(file, stringtowrite, 12);
	write_file(file, stringtowrite, 12);
	write_file(file, stringtowrite, 12);
	printf("written to file\n");
	close_file(file);

	file = open_dirent(&entry, FILE_MODE_EXC_READ);
	printf("file handle at %04x\n", file);
	read_file(file, buffer, 200);
	printf("read back 200 chars at %04x\n", buffer);
	close_file(file);
	
	file = create_file(&dir, newfilename, FILE_MODE_EXC_WRITE);
	printf("opened handle to new file at %04x\n", file);
	write_file(file, string2, 18);
	close_file(file);

	file = open_dirent(&entry, FILE_MODE_EXC_READ);
	printf("file handle at %04x\n", file);
	read_file(file, buffer, 200);
	printf("read back 200 chars at %04x\n", buffer);
	close_file(file);

	#asm
	ei
	#endasm

	return 0;
}
