#include <stdio.h>

#include "../include/divide.h"
#include "../include/mbr.h"
#include "../include/buffer.h"
#include "../include/lowio.h"
#include "../include/fatfs.h"

FILESYSTEM fs;
DIR dir;
DIRENT entry;
BLOCK_DEVICE *device;
PARTITION_INFO pi;
BLOCK_DEVICE *partition;

int main() {
	unsigned char i,j;
	
	/* avoid issues with the interrupt routine hijacking the IY register -
	not sure how big a problem this really is, but can't hurt... */
	#asm
	di
	#endasm
	
	mbr_init();
	fatfs_init();
	buffer_emptybuffers(); // TODO: Can this be sensibly incorporated into fatfs_init?
	
	device = divide_open_drive(DIVIDE_DRIVE_MASTER);
	if (mbr_has_boot_signature(device)) {
		printf("YES, this device has an MBR\n");
		for (i = 0; i < 4; i++) {
			mbr_get_partition_info(device, i, pi);
			printf("Partition %d: type %02x, starting at %08lx\n", i, pi.partition_type, pi.start_block);
			if (pi.partition_type == PARTITION_TYPE_FAT16_SMALL
				|| pi.partition_type == PARTITION_TYPE_FAT16_LARGE
				|| pi.partition_type == PARTITION_TYPE_FAT16_LBA) {
				
				printf("partition info at %04x\n", &pi);
				
				partition = mbr_open_partition(pi);
				printf("opened partition %04x backed by drive %04x\n", partition, device);
				fatfs_fsopen(partition, &fs);
				printf("fatfs filesystem at %04x\n", &fs);
				open_root_dir(&fs, &dir);
				printf("dir handle at %04x\n", &dir);
				for (j = 0; j < 13; j++) {
					read_dir(&dir, &entry);
					printf("%s\n", entry.filename);
				}
				break;
			}
		}
	} else {
		printf("NO, this device doesn't have an MBR\n");
	}

	#asm
	ei
	#endasm

	return 0;
}
