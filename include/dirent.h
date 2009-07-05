#ifndef __DIRENT_H__
#define __DIRENT_H__

#define NAME_MAX 32 /* maximum length of a filename in bytes */

typedef struct dirent {
	char d_name[NAME_MAX];
	/* FIXME: the following fields are trdos-specific and really shouldn't be */
	unsigned char sector_count;
	unsigned char start_sector;
	unsigned char start_track;
} DIRENT;

#endif
