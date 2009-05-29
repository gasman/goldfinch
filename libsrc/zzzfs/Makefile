CFILES = \
	open.c \
	readbyte.c \
	read.c

AFILES = \
	close.asm \
	creat.asm \
	fdgetpos.asm \
	fdtell.asm \
	lseek.asm \
	open_z88.asm \
	remove.asm \
	rename.asm \
	write.asm \
	writebyte.asm

OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/zzzfs.lib

../../lib/zzzfs.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/zzzfs $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
