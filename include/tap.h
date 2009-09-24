#ifndef __TAP_H__
#define __TAP_H__

#include "lowio.h"

extern void __LIB__ __CALLEE__ tap_load_block_callee(FSFILE *file, void *buf, unsigned int length, unsigned char block_type);
extern void __LIB__ __CALLEE__ tap_save_block_callee(FSFILE *file, void *buf, unsigned int length, unsigned char block_type);

#define tap_load_block(a,b,c,d) tap_load_block_callee(a,b,c,d)
#define tap_save_block(a,b,c,d) tap_save_block_callee(a,b,c,d)

#endif
