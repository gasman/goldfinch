CFILES = 

AFILES = \
	mbr_init.asm \
	mbr_data.asm \
	mbr_has_boot_signature.asm \
	mbr_get_partition_info_callee.asm \
	mbr_open_partition.asm
	
OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/mbr.lib

../../lib/mbr.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/mbr $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
