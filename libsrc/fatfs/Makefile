CFILES = 

AFILES = \
	buf_emptybuffers.asm \
	buf_setmru.asm \
	buf_gethandle.asm \
	buf_findbuf_noread.asm \
	buf_flushone.asm \
	buf_writebuf.asm \
	buf_findbuf.asm \
	buf_update.asm \
	buf_flushbuffers.asm \
	fat_readfat.asm \
	fat_writefat.asm \
	clus_getsector.asm \
	clus_readtobuf.asm \
	clus_tobuf_noread.asm \
	clus_readtomem.asm \
	clus_writefrommem.asm \
	clus_nextsector.asm \
	clus_valid.asm \
	clus_allocate.asm \
	clus_extendchain.asm \
	clus_freechain.asm \
	clus_erase.asm \
	dir_root.asm \
	dir_home.asm \
	dir_change.asm \
	dir_entrydetails.asm \
	dir_getentry.asm \
	dir_next.asm \
	dir_getfree.asm \
	dir_findvolumelabel.asm \
	dir_validchar.asm \
	dir_parsefilename.asm \
	drive_getdircopy.asm \
	drive_getdirhandle.asm \
	drive_refdir.asm \
	dir_getfirstmatch.asm \
	dir_matchname.asm \
	dir_catalog.asm \
	dir_path.asm \
	file_delete.asm \
	file_isopen.asm \
	file_create_entry.asm \
	drive_init.asm \
	fatfs_init.asm

OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/fatfs.lib

../../lib/fatfs.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/fatfs $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
