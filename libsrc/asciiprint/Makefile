CFILES = 

AFILES = \
	asciiprint_data.asm \
	asciiprint_putchar.asm \
	asciiprint_calcpos.asm \
	asciiprint_setpos.asm \
	asciiprint_print.asm \
	asciiprint_newline.asm \
	asciiprint_backspace.asm
	
OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/asciiprint.lib

../../lib/asciiprint.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/asciiprint $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
