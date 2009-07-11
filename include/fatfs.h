#include "block_device.h"

/* equivalent to a 'partition handle' in fatfs.def */
typedef struct fatfs_filesystem_st {
	struct block_device_st block_device;
	unsigned char fph_fattype;
	unsigned int fph_fatsize;
	unsigned char fph_fat_copies;
	unsigned char fph_fat1_start[3];
	unsigned int fph_rootsize;
	unsigned char fph_root_start[3];
	unsigned char fph_clussize;
	unsigned int fph_maxclust;
	unsigned int fph_lastalloc;
	unsigned char fph_data_start[3];
	unsigned char fph_primary;
	unsigned char fph_secondary;
	unsigned int fph_freeclusts;
} FATFS_FILESYSTEM;

extern void __LIB__ __FASTCALL__ fatfs_init(void);
extern void __LIB__ fatfs_drive_init(BLOCK_DEVICE *device, FATFS_FILESYSTEM *fs);

// And now a list of the same non-FASTCALL functions using CALLEE linkage
extern void __LIB__ __CALLEE__ fatfs_drive_init_callee(BLOCK_DEVICE *device, FATFS_FILESYSTEM *fs);

// And now we make CALLEE linkage default to make compiled progs shorter and faster
// These defines will generate warnings for function pointers but that's ok
#define fatfs_drive_init(a,b)	fatfs_drive_init_callee(a,b)
