#ifndef __LOWIO_H__
#define __LOWIO_H__

typedef struct filesystem_driver_st FILESYSTEM_DRIVER;

/* Filesystem handle */
typedef struct filesystem_st {
	FILESYSTEM_DRIVER *driver;
	void *data;	// driver-specific data
} FILESYSTEM;

/* Directory handle */
typedef struct dir_st {
	FILESYSTEM fs; /* copy of the corresponding filesystem handle */
	union dir_fs_data_u {
		struct trdos_dir_fs_data_st {
			unsigned int block_number; /* block number that the directory pointer currently sits in */
			unsigned char block_offset; /* offset into the (256-byte) sector where the next dir entry is */
		} trdos_dir_fs_data;
	} dir_fs_data;
} DIR;

#define MAX_NAME 32
/* Directory entry record */
typedef struct dirent_st {
	DIR *dir; /* pointer to the dir (and thus the filesystem) object */
	char filename[MAX_NAME]; /* null-terminated filename */
	unsigned char flags; /* bit field; bit 0 set if this is a directory */
	union dirent_fs_data_u { /*  filesystem-specific state; enough to open the file */
		struct trdos_dirent_fs_data_st {
			unsigned char sector_count;
			unsigned char start_sector;
			unsigned char start_track;
		} trdos_dirent_fs_data;
	} dirent_fs_data;
} DIRENT;

/* File record */
typedef struct fsfile_st {
	FILESYSTEM fs; /* Copy of the corresponding filesystem handle */
	union file_fs_data_u { /* filesystem-specific state */
		struct trdos_file_fs_data_st {
			unsigned int block_number; /* block number that the file pointer currently sits in */
			unsigned char block_offset; /* offset into the (256-byte) sector where the next byte is */
			unsigned char remaining_blocks; /* number of blocks left to read before EOF */
		} trdos_file_fs_data;
	} file_fs_data;
} FSFILE;

// First a list of functions using CALLER and FASTCALL linkage

// And now a list of the same non-FASTCALL functions using CALLEE linkage
extern void __LIB__ __CALLEE__ open_root_dir_callee(FILESYSTEM *fs, DIR *dir);
extern int __LIB__ __CALLEE__ read_dir_callee(DIR *dir, DIRENT *dirent);
extern int __LIB__ __CALLEE__ open_dirent_callee(DIRENT *dirent, FSFILE *file);
extern int __LIB__ __CALLEE__ read_file_callee(FSFILE *file, void *buf, unsigned int nbyte);

// And now we make CALLEE linkage default to make compiled progs shorter and faster
// These defines will generate warnings for function pointers but that's ok
#define open_root_dir(a,b) open_root_dir_callee(a,b)
#define read_dir(a,b) read_dir_callee(a,b)
#define open_dirent(a,b) open_dirent_callee(a,b)
#define read_file(a,b,c) read_file_callee(a,b,c)

#endif
