#include <fcntl.h>

size_t read(int fd, void *ptr, size_t len) {
	int i;
	for (i = 0; i < len; i++) {
		*ptr = 'z';
		ptr++;
	}
	return len;
}
