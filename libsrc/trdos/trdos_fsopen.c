#include "../../include/trdos.h"

void trdos_fsopen(BLOCK_DEVICE *device, TRDOS_FILESYSTEM *fs) {
	fs->block_device = device;
}
