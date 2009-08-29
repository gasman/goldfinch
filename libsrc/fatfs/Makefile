CFILES = 

AFILES = \
	fatfs_data.asm \
	fatfs_fat_readfat.asm \
	fatfs_fat_writefat.asm \
	fatfs_clus_getsector.asm \
	fatfs_clus_readtobuf.asm \
	fatfs_clus_tobuf_noread.asm \
	fatfs_clus_readtomem.asm \
	fatfs_clus_writefrommem.asm \
	fatfs_clus_nextsector.asm \
	fatfs_clus_valid.asm \
	fatfs_clus_allocate.asm \
	fatfs_clus_extendchain.asm \
	fatfs_clus_freechain.asm \
	fatfs_clus_erase.asm \
	fatfs_file_isopen.asm \
	fatfs_init.asm \
	fatfs_fsopen.asm \
	fatfs_fsopen_callee.asm \
	fatfs_open_root_dir.asm \
	fatfs_dir_home.asm \
	fatfs_dir_getentry.asm \
	fatfs_dir_entrydetails.asm \
	fatfs_dir_next.asm \
	fatfs_read_dir.asm \
	fatfs_open_dirent.asm \
	fatfs_read_file.asm \
	fatfs_file_checkfilepos.asm \
	fatfs_file_getvalidaddr.asm \
	fatfs_file_getfilepos.asm \
	fatfs_file_addfpos.asm  \
	fatfs_file_set_access.asm \
	fatfs_file_commit.asm \
	fatfs_phandle_allocate.asm \
	fatfs_file_allocate.asm

OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/fatfs.lib

../../lib/fatfs.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/fatfs $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
