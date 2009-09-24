CFILES = 

AFILES = \
	open_root_dir_callee.asm \
	read_dir_callee.asm \
	open_dirent_callee.asm \
	read_file_callee.asm \
	close_file.asm \
	open_subdir_callee.asm \
	dir_home.asm \
	write_file_callee.asm \
	create_file_callee.asm \
	seek_file_callee.asm \
	read_byte.asm \
	get_file_pos.asm \
	write_byte_callee.asm \
	flush_file.asm \
	file_is_eof.asm

OBJECTS = $(CFILES:.c=.o)
MODULE_NAMES = $(OBJECTS:.o=) $(AFILES:.asm=)

all: ../../lib/lowio.lib

../../lib/lowio.lib: $(OBJECTS) $(AFILES)
	z80asm -d -nv -ns -nm -Mo -x../../lib/lowio $(MODULE_NAMES)

.c.o:
	zcc +zx -vn -c $*.c 

clean:
	rm -f *.sym *.map zcc_opt.def *.o*
