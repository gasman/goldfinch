#include "include/fatfs.h"
#include "include/divide.h"
#include <stdio.h>

int main() {
	BLOCK_DEVICE *divide_master;
	FATFS_FILESYSTEM fat;
	FATFS_DIRECTORY dir;

	printf("Initializing fatfs library\n");
	fatfs_init();
	printf("opening DivIDE master drive\n");
	divide_master = divide_open_drive(DIVIDE_DRIVE_MASTER);
	printf("initializing fat fs on drive\n");
	fatfs_drive_init(divide_master, &fat);
	printf("fetching root dir\n");
	fatfs_dir_root(&fat, &dir);
	printf("Done. Dir handle is at %d\n", &dir);
	return 0;
}
