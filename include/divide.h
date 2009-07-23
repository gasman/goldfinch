#ifndef __DIVIDE_H__
#define __DIVIDE_H__

#include "block_device.h"

// drive ID codes (constructed as (drive number << 4) | 0x40, which is the top 4 bits we send to the drive/head register)
#define DIVIDE_DRIVE_MASTER 0x40
#define DIVIDE_DRIVE_SLAVE 0x50

// First a list of functions using CALLER and FASTCALL linkage
extern void __LIB__ divide_read_block(BLOCK_DEVICE *device, void *buffer, unsigned long block_number);
extern void __LIB__ divide_write_block(BLOCK_DEVICE *device, void *buffer, unsigned long block_number);
extern BLOCK_DEVICE __LIB__ __FASTCALL__ *divide_open_drive(unsigned char drive_number);

// And now a list of the same non-FASTCALL functions using CALLEE linkage
extern void __LIB__ __CALLEE__ divide_read_block_callee(BLOCK_DEVICE *device, void *buffer, unsigned long block_number);
extern void __LIB__ __CALLEE__ divide_write_block_callee(BLOCK_DEVICE *device, void *buffer, unsigned long block_number);

// And now we make CALLEE linkage default to make compiled progs shorter and faster
// These defines will generate warnings for function pointers but that's ok

#define divide_read_block(a,b,c)	divide_read_block_callee(a,b,c)
#define divide_write_block(a,b,c)	divide_write_block_callee(a,b,c)

#endif
