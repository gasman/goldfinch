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

int main() {
	BLOCK_DEVICE *device;
	void *test_alloc;

	mallinit();
	sbrk(55000,5000);
	
	buffer_emptybuffers(); // TODO: Can this be sensibly incorporated into fatfs_init?

	test_alloc = u_malloc(42);
	printf("test allocation of 42 bytes, allocated at %04x\n", test_alloc);

	printf("Initializing fatfs library\n");
	fatfs_init();
	printf("opening DivIDE master drive\n");
	device = divide_open_drive(DIVIDE_DRIVE_MASTER);
	printf("opening FATfs filesystem on it\n");
	fatfs_fsopen(device, &fs);
	printf("fatfs filesystem at %04x\n", &fs);

	return 0;
}
