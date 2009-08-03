#ifndef __TRDOS_H__
#define __TRDOS_H__

#include "block_device.h"
#include "lowio.h"

extern void __LIB__ trdos_fsopen(BLOCK_DEVICE *device, FILESYSTEM *fs);

/* callee definitions */
extern void __LIB__ __CALLEE__ trdos_fsopen_callee(BLOCK_DEVICE *device, FILESYSTEM *fs);
extern void __LIB__ __CALLEE__ trdos_open_root_dir_callee(FILESYSTEM *fs, DIR *dir);
extern int __LIB__ __CALLEE__ trdos_read_dir_callee(DIR *dir, DIRENT *dirent);
extern int __LIB__ __CALLEE__ trdos_open_dirent_callee(DIRENT *dirent, FSFILE *file);
extern int __LIB__ __CALLEE__ trdos_read_file_callee(FSFILE *file, void *buf, unsigned int nbyte);

/* set up to use callee when doing plain non-function-pointer calls */
#define trdos_fsopen(a,b) trdos_fsopen_callee(a,b)
#define trdos_open_root_dir(a,b) trdos_open_root_dir_callee(a,b)
#define trdos_read_dir(a,b) trdos_read_dir_callee(a,b)
#define trdos_open_dirent(a,b) trdos_open_dirent_callee(a,b)
#define trdos_read_file(a,b,c) trdos_read_file_callee(a,b,c)

#endif
