CFILES = 

AFILES = \
	trdos_data.asm \
	trdos_init.asm \
	trdos_file_allocate.asm \
	trdos_fsopen.asm \
	trdos_fsopen_callee.asm \
	trdos_open_root_dir.asm \
	trdos_read_dir.asm \
	trdos_open_dirent.asm \
	trdos_read_file.asm \
	trdos_dir_get_entry.asm \
	trdos_dir_next.asm \
	trdos_close_file.asm

OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/trdos.lib

../../lib/trdos.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/trdos $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
