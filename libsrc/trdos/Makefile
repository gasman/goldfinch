CFILES = \
	trdos_readdir.c \
	trdos_read.c

AFILES = \
	trdos_fsopen.asm \
	trdos_fsopen_callee.asm \
	trdos_open_dirent.asm \
	trdos_open_dirent_callee.asm \
	trdos_opendir.asm \
	trdos_opendir_callee.asm

OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/trdos.lib

../../lib/trdos.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/trdos $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
