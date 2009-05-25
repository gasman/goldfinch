#ifndef __BLOCK_DEVICE_H__
#define __BLOCK_DEVICE_H__

/* typedef struct block_device_driver_st {
	void (*read_block)(struct block_device_st device, void *buffer, unsigned long block_number)
} BLOCK_DEVICE_DRIVER;

typedef struct block_device_st {
	BLOCK_DEVICE_DRIVER *type,
	void *data	// driver-specific data
} BLOCK_DEVICE;
*/
typedef struct block_device_st BLOCK_DEVICE;

extern void __LIB__ read_block(BLOCK_DEVICE *, void *, unsigned long block_number);

#endif
