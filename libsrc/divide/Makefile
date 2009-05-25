#
# Wahey, a messed up makefile for building libraries!
# $Id:$
#

AFILES = \
	divide_read_sector.asm \
	divide_read_sector_callee.asm \
	divide_open_drive.asm

all: ../../lib/divide.lib

../../lib/divide.lib: $(AFILES) divide.lst
	z80asm -x../../lib/divide @divide.lst

clean:
	rm -f *.o* *.sym *.map *.err zcc_opt.def *.i

