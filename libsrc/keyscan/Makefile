CFILES = 

AFILES = \
	keyscan_data.asm \
	keyscan_scan.asm \
	keyscan_table_unshifted.asm \
	keyscan_table_symshift.asm \
	keyscan_table_capsshift.asm \
	keyscan_wait_key.asm
	
OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/keyscan.lib

../../lib/keyscan.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/keyscan $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
