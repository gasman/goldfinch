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

/* directory handle */
typedef struct fatfs_directory_st {
	FATFS_FILESYSTEM *fs; /* partition handle */
	unsigned char flags; /* bit 7=1 for root */
	unsigned int clusstart; /*  start cluster (0 for root) */
	unsigned char sector; /* current sector */
	unsigned int cluster; /* current cluster (sector offset for root) */
	unsigned int entry; /* current entry within sector */
	unsigned char size; /* dummy; FIXME - check that it's safe to omit this in the C definition */
} FATFS_DIRECTORY;

typedef struct fatfs_dir_entry_st {
	char name[8];
	char ext[3]; /* extension */
	unsigned char attr; /* attributes */
	unsigned char unused[10]; /* not used without LFN */
	unsigned int time;
	unsigned int date;
	unsigned int cluster; /* start cluster */
	unsigned long filesize; /* size in bytes */
} FATFS_DIR_ENTRY;

extern void __LIB__ __FASTCALL__ fatfs_init(void);
extern void __LIB__ fatfs_drive_init(BLOCK_DEVICE *device, FATFS_FILESYSTEM *fs);
extern void __LIB__ fatfs_dir_root(FATFS_FILESYSTEM *fs, FATFS_DIRECTORY *dir);
extern FATFS_DIR_ENTRY __LIB__ *fatfs_dir_entrydetails(FATFS_DIRECTORY *dir, FATFS_FILESYSTEM *fs);

// And now a list of the same non-FASTCALL functions using CALLEE linkage
extern void __LIB__ __CALLEE__ fatfs_drive_init_callee(BLOCK_DEVICE *device, FATFS_FILESYSTEM *fs);
extern void __LIB__ __CALLEE__ fatfs_dir_root_callee(FATFS_FILESYSTEM *fs, FATFS_DIRECTORY *dir);
extern FATFS_DIR_ENTRY __LIB__ __CALLEE__ *fatfs_dir_entrydetails_callee(FATFS_DIRECTORY *dir, FATFS_FILESYSTEM *fs);

// And now we make CALLEE linkage default to make compiled progs shorter and faster
// These defines will generate warnings for function pointers but that's ok
#define fatfs_drive_init(a,b)	fatfs_drive_init_callee(a,b)
#define fatfs_dir_root(a,b)	fatfs_dir_root_callee(a,b)
#define fatfs_dir_entrydetails(a,b)	fatfs_dir_entrydetails_callee(a,b)
