#ifndef __BUFFER_H__
#define __BUFFER_H__

#include "block_device.h"

// First a list of functions using CALLER and FASTCALL linkage
extern void __LIB__ __FASTCALL__ buffer_emptybuffers(void);

// And now a list of the same non-FASTCALL functions using CALLEE linkage
extern void __LIB__ __CALLEE__ *buffer_findbuf_callee(BLOCK_DEVICE *device, unsigned long block_number);

// And now we make CALLEE linkage default to make compiled progs shorter and faster
// These defines will generate warnings for function pointers but that's ok
#define buffer_findbuf(a,b)	buffer_findbuf_callee(a,b)

#endif
