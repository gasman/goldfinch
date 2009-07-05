CFILES = \
	trdos_fsopen.c \
	trdos_opendir.c \
	trdos_readdir.c \
	trdos_open_dirent.c \
	trdos_read.c

AFILES = 

OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/trdos.lib

../../lib/trdos.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/trdos $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
