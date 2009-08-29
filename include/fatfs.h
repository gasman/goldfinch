#ifndef __FATFS_H__
#define __FATFS_H__

#include "block_device.h"
#include "lowio.h"

extern void __LIB__ __FASTCALL__ fatfs_init(void);
extern void __LIB__ fatfs_fsopen(BLOCK_DEVICE *device, FILESYSTEM *fs);

// And now a list of the same non-FASTCALL functions using CALLEE linkage
extern void __LIB__ __CALLEE__ fatfs_fsopen_callee(BLOCK_DEVICE *device, FILESYSTEM *fs);

// And now we make CALLEE linkage default to make compiled progs shorter and faster
// These defines will generate warnings for function pointers but that's ok
#define fatfs_fsopen(a,b) fatfs_fsopen_callee(a,b)

#endif
