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
	fat_writefat.asm

OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/fatfs.lib

../../lib/fatfs.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/fatfs $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
