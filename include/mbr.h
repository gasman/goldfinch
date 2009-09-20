#ifndef __MBR_H__
#define __MBR_H__

#include "block_device.h"

typedef struct partition_info_st {
	BLOCK_DEVICE *block_device; /* pointer to the block device with this partition on */
	unsigned char partition_type;
	unsigned long start_block;
} PARTITION_INFO;

#define PARTITION_TYPE_EMPTY 0x00
#define PARTITION_TYPE_FAT12 0x01
#define PARTITION_TYPE_FAT16_SMALL 0x04
#define PARTITION_TYPE_EXTENDED 0x05
#define PARTITION_TYPE_FAT16_LARGE 0x06
#define PARTITION_TYPE_FAT32 0x0b
#define PARTITION_TYPE_FAT32_LBA 0x0c
#define PARTITION_TYPE_FAT16_LBA 0x0e
#define PARTITION_TYPE_EXTENDED_LBA 0x0f
#define PARTITION_TYPE_ALTOS 0x7f

extern void __LIB__ __FASTCALL__ mbr_init(void);
extern unsigned char __LIB__ __FASTCALL__ mbr_has_boot_signature(BLOCK_DEVICE *device);
extern void __LIB__ __CALLEE__ mbr_get_partition_info_callee(BLOCK_DEVICE *device, unsigned char partition_number, PARTITION_INFO *partition_info);
extern BLOCK_DEVICE __LIB__ __FASTCALL__ *mbr_open_partition(PARTITION_INFO *partition_info);

#define mbr_get_partition_info(a,b,c) mbr_get_partition_info_callee(a,b,c)

#endif
