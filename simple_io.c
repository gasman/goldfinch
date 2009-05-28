#include <fcntl.h>
#include <stdio.h>

int main() {
	int fd;
	int response;
	int count;
	FILE *file;
	
	int b;
	char *buf = "0123456789";
	unsigned char *buf2 = "0123456789";
	
	fd = open("foo.txt", O_RDONLY, 0);
	printf("open returned file descriptor %d\n", fd);
	
	if (fd != -1) {
		b = readbyte(fd);
		printf("character read from fd: %d\n", b);
		printf("buffer at %d contained: %s\n", buf, buf);
		count = read(fd, (void *)buf, 10);
		printf("%d more characters read from fd, buffer at %d: %s\n", count, buf, buf);
		response = close(fd);
		printf("close returned response %d\n", response);
	}
	
	printf("And again with stdio:\n");
	file = fopen("foo.txt", "r");
	if (file != NULL) {
		/* fgets(buf2, 10, file); */
		fread(buf2, 10, 1, file);
		printf("Characters read: %s\n", buf2);
		fclose(file);
	}
	
	return 0;
}
