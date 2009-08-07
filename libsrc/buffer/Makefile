CFILES = 

AFILES = \
	buffer_data.asm \
	buffer_emptybuffers.asm \
	buffer_setmru.asm \
	buffer_gethandle.asm \
	buffer_findbuf_noread.asm \
	buffer_flushone.asm \
	buffer_writebuf.asm \
	buffer_findbuf.asm \
	buffer_update.asm \
	buffer_flushbuffers.asm \
	buffer_findbuf_callee.asm
	
ASUPPORTFILES = \
	buffer.def

OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/buffer.lib

../../lib/buffer.lib: $(OBJECTS) $(AFILES) $(ASUPPORTFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/buffer $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
