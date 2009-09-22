CFILES = 

AFILES = \
	clairsys_font.asm
	
OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/clairsys_font.lib

../../lib/clairsys_font.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/clairsys_font $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
