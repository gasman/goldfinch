#include "../include/fatfs.h"
#include "../include/divide.h"
#include <stdio.h>

int main() {
	BLOCK_DEVICE *divide_master;
	FATFS_FILESYSTEM fat;
	FATFS_DIRECTORY dir;
	FATFS_DIR_ENTRY *dir_entry;

	printf("Initializing fatfs library\n");
	fatfs_init();
	printf("opening DivIDE master drive\n");
	divide_master = divide_open_drive(DIVIDE_DRIVE_MASTER);
	printf("initializing fat fs on drive\n");
	fatfs_drive_init(divide_master, &fat);
	printf("fetching root dir\n");
	fatfs_dir_root(&fat, &dir);
	printf("Dir handle is at %d - fetching dir entry\n", &dir);
	dir_entry = fatfs_dir_entrydetails(&dir, &fat);
	printf("filename is: %s", dir_entry->name);
	return 0;
}
