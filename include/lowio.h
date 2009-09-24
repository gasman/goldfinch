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
	union dir_fsdata_u {
		struct dir_fsdata_trdos_st {
			unsigned int block_number; /* block number that the directory pointer currently sits in */
			unsigned char block_offset; /* offset into the (256-byte) sector where the next dir entry is */
		} trdos;
		struct dir_fsdata_fatfs_st {
			unsigned char flags; /* bit 7=1 for root */
			unsigned int clusstart; /*  start cluster (0 for root) */
			unsigned char sector; /* current sector */
			unsigned int cluster; /* current cluster (sector offset for root) */
			unsigned char entry; /* current entry within sector */
		} fatfs;
	} dir_fsdata;
} DIR;

#define MAX_NAME 32
/* Directory entry record */
typedef struct dirent_st {
	DIR dir; /* copy of the dir (and thus the filesystem) object */
	char filename[MAX_NAME]; /* null-terminated filename */
	unsigned char flags; /* bit field; bit 0 set if this is a directory */
	/*  filesystem-specific state; enough to open the file - probably not needed, as the dir record is enough */
	/* union dirent_fsdata_u { 
	} dirent_fsdata; */
} DIRENT;

/* File record */
typedef struct fsfile_st {
	FILESYSTEM fs; /* Copy of the corresponding filesystem handle */
	union file_fsdata_u { /* filesystem-specific state */
		struct file_fsdata_trdos_st {
			unsigned int block_number; /* block number that the file pointer currently sits in */
			unsigned char block_offset; /* offset into the (256-byte) sector where the next byte is */
			unsigned char remaining_blocks; /* number of blocks left to read before EOF */
		} trdos;
		struct file_fsdata_fatfs_st {
			unsigned char mode; /* file mode flags (0 if handle free) */
			unsigned int cluster; /* current cluster */
			unsigned char sector; /* current sector */
			unsigned int offset; /* current pos within sector */
			unsigned long filepos; /* filepointer */
			unsigned int clusstart; /* start cluster */
			unsigned long filesize; /* exact filesize in bytes */
		} fatfs;
	} file_fsdata;
} FSFILE;

/* file access modes - snarfed from fatfs.def */
#define FILE_MODE_EXC_READ 1
#define FILE_MODE_EXC_WRITE 2
#define FILE_MODE_EXC_RW 3
#define FILE_MODE_SHARED_READ 5

// First a list of functions using CALLER and FASTCALL linkage
extern void __LIB__ __FASTCALL__ close_file(FSFILE *file);
extern void __LIB__ __FASTCALL__ dir_home(DIR *dir);
extern unsigned char __LIB__ __FASTCALL__ read_byte(FSFILE *file);
extern unsigned long __LIB__ __FASTCALL__ get_file_pos(FSFILE *file);
extern void __LIB__ __FASTCALL__ flush_file(FSFILE *file);
extern unsigned int __LIB__ __FASTCALL__ file_is_eof(FSFILE *file);

// And now a list of the same non-FASTCALL functions using CALLEE linkage
extern void __LIB__ __CALLEE__ open_root_dir_callee(FILESYSTEM *fs, DIR *dir);
extern int __LIB__ __CALLEE__ read_dir_callee(DIR *dir, DIRENT *dirent);
extern FSFILE __LIB__ __CALLEE__ *open_dirent_callee(DIRENT *dirent, unsigned char access_mode);
extern int __LIB__ __CALLEE__ read_file_callee(FSFILE *file, void *buf, unsigned int nbyte);
extern int __LIB__ __CALLEE__ open_subdir_callee(DIRENT *dirent, DIR *dir);
extern int __LIB__ __CALLEE__ write_file_callee(FSFILE *file, void *buf, unsigned int nbyte);
extern FSFILE __LIB__ __CALLEE__ *create_file_callee(DIR *dir, char *filename, unsigned char access_mode);
extern void __LIB__ __CALLEE__ seek_file_callee(FSFILE *file, unsigned long pos);
extern void __LIB__ __CALLEE__ write_byte_callee(FSFILE *file, unsigned char byte);

// And now we make CALLEE linkage default to make compiled progs shorter and faster
// These defines will generate warnings for function pointers but that's ok
#define open_root_dir(a,b) open_root_dir_callee(a,b)
#define read_dir(a,b) read_dir_callee(a,b)
#define open_dirent(a,b) open_dirent_callee(a,b)
#define read_file(a,b,c) read_file_callee(a,b,c)
#define open_subdir(a,b) open_subdir_callee(a,b)
#define write_file(a,b,c) write_file_callee(a,b,c)
#define create_file(a,b,c) create_file_callee(a,b,c)
#define seek_file(a,b) seek_file_callee(a,b)
#define write_byte(a,b) write_byte_callee(a,b)

#endif
