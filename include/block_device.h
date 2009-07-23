#ifndef __BLOCK_DEVICE_H__
#define __BLOCK_DEVICE_H__

/* typedef struct block_device_driver_st {
	void (*read_block)(struct block_device_st device, void *buffer, unsigned long block_number)
} BLOCK_DEVICE_DRIVER;
*/

typedef struct block_device_driver_st BLOCK_DEVICE_DRIVER;

typedef struct block_device_st {
	BLOCK_DEVICE_DRIVER *type;
	void *data;	// driver-specific data
} BLOCK_DEVICE;

// First a list of functions using CALLER and FASTCALL linkage
extern void __LIB__ read_block(BLOCK_DEVICE *device, void *buffer, unsigned long block_number);
extern void __LIB__ write_block(BLOCK_DEVICE *device, void *buffer, unsigned long block_number);

// And now a list of the same non-FASTCALL functions using CALLEE linkage
extern void __LIB__ __CALLEE__ read_block_callee(BLOCK_DEVICE *device, void *buffer, unsigned long block_number);
extern void __LIB__ __CALLEE__ write_block_callee(BLOCK_DEVICE *device, void *buffer, unsigned long block_number);

// And now we make CALLEE linkage default to make compiled progs shorter and faster
// These defines will generate warnings for function pointers but that's ok
#define read_block(a,b,c)	read_block_callee(a,b,c)
#define write_block(a,b,c)	write_block_callee(a,b,c)

#endif
