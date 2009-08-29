#ifndef __TRDOS_H__
#define __TRDOS_H__

#include "block_device.h"
#include "lowio.h"

extern void __LIB__ __FASTCALL__ trdos_init(void);
extern void __LIB__ trdos_fsopen(BLOCK_DEVICE *device, FILESYSTEM *fs);

/* callee definitions */
extern void __LIB__ __CALLEE__ trdos_fsopen_callee(BLOCK_DEVICE *device, FILESYSTEM *fs);

/* set up to use callee when doing plain non-function-pointer calls */
#define trdos_fsopen(a,b) trdos_fsopen_callee(a,b)

#endif
