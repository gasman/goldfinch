#include "include/fatfs.h"
#include "include/divide.h"

int main() {
	BLOCK_DEVICE *divide_master;
	FATFS_FILESYSTEM fat;

	fatfs_init();
	divide_master = divide_open_drive(DIVIDE_DRIVE_MASTER);
	fatfs_drive_init(divide_master, &fat);
	return 0;
}
