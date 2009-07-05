#include "../../include/trdos.h"
#include "../../include/block_device.h"

ssize_t __LIB__ trdos_read(TRDOS_FILESYSTEM *fs, TRDOS_FILE *file, void *buf, size_t nbyte) {
	ssize_t bytes_read = 0;
	unsigned char *buffer_end = file->block_buffer + 256;
	while (bytes_read < nbyte) {
		if (file->pos >= buffer_end) { /* end of block buffer reached */
			/* are we at EOF? */
			if (file->blocks_read >= file->block_count) {
				break;
			} else { /* read next block */
				read_block(fs->block_device, file->block_buffer, file->block_number);
				file->block_number++;
				file->blocks_read++;
				file->pos = file->block_buffer;
			}
		}
		/* now we're ok to copy a byte */
		*buf = *(file->pos);
		buf++;
		file->pos++;
		bytes_read++;
	}
	return bytes_read;
}
