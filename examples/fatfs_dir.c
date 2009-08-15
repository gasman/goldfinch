#include <stdio.h>
#include <malloc.h>

#include "../include/fatfs.h"
#include "../include/divide.h"
#include "../include/buffer.h"

long heap;

/* Memory allocation routines required by fatfs */
void *u_malloc(int size) {
   return malloc(size);             // let malloc take care of things; carry flag set properly by the malloc() call
}
 
void u_free(void *addr) {
   free(addr);                      // free() deallocates memory allocated by malloc() and ignores addr==0
}

FILESYSTEM fs;
DIR dir;
DIRENT entry;

int main() {
	BLOCK_DEVICE *device;
	unsigned char i;

	mallinit();
	sbrk(55000,5000);
	
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
	for (i = 0; i < 12; i++) {
		read_dir(&dir, &entry);
		printf("%s\n", entry.filename);
	}

	return 0;
}
