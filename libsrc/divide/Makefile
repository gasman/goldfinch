CFILES = 

AFILES = \
	divide_read_block.asm \
	divide_read_block_callee.asm \
	divide_write_block.asm \
	divide_write_block_callee.asm \
	divide_open_drive.asm

OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/divide.lib

../../lib/divide.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/divide $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
