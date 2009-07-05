#ifndef __DIRENT_H__
#define __DIRENT_H__

#define NAME_MAX 32 /* maximum length of a filename in bytes */

typedef struct dirent {
	char d_name[NAME_MAX];
} DIRENT;

#endif
