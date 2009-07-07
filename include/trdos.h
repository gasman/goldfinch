#ifndef __TRDOS_H__
#define __TRDOS_H__

#include <sys/types.h>
#include "block_device.h"
#include "dirent.h"

typedef struct trdos_filesystem_st {
	BLOCK_DEVICE *block_device;
} TRDOS_FILESYSTEM;

typedef struct trdos_dir_st {
	unsigned long block_number; /* the block number of the block currently loaded into block_buffer */
	unsigned char *current_dir_entry; /* the pointer into block_buffer to the next unread directory entry */
	unsigned char block_buffer[512]; /* can make this [256] once we're assured of a block_device that serves blocks of 256 bytes */
} TRDOS_DIR;

typedef struct trdos_file_st {
	unsigned long block_number; /* the block number of the block currently loaded into block_buffer */
	unsigned char blocks_read;
	unsigned char block_count;
	unsigned char *pos; /* position within block_buffer */
	unsigned char block_buffer[512]; /* can make this [256] once we're assured of a block_device that serves blocks of 256 bytes */
} TRDOS_FILE;

extern void __LIB__ trdos_fsopen(BLOCK_DEVICE *, TRDOS_FILESYSTEM *);
extern void __LIB__ trdos_opendir(TRDOS_FILESYSTEM *, TRDOS_DIR *);
extern int __LIB__ trdos_readdir(TRDOS_FILESYSTEM *, TRDOS_DIR *, DIRENT *); /* returns 0 if at end of dir */
extern void __LIB__ trdos_open_dirent(TRDOS_FILESYSTEM *, DIRENT *, TRDOS_FILE *);
extern ssize_t __LIB__ trdos_read(TRDOS_FILESYSTEM *, TRDOS_FILE *, void *, size_t);


/* callee definitions */
extern void __LIB__ __CALLEE__ trdos_fsopen_callee(BLOCK_DEVICE *, TRDOS_FILESYSTEM *);
extern void __LIB__ __CALLEE__ trdos_open_dirent_callee(TRDOS_FILESYSTEM *, DIRENT *, TRDOS_FILE *);
extern void __LIB__ __CALLEE__ trdos_opendir_callee(TRDOS_FILESYSTEM *, TRDOS_DIR *);

/* set up to use callee when doing plain non-function-pointer calls */
#define trdos_fsopen(a,b) trdos_fsopen_callee(a,b)
#define trdos_open_dirent(a,b,c) trdos_open_dirent_callee(a,b,c)
#define trdos_opendir(a,b) trdos_opendir_callee(a,b)

#endif
