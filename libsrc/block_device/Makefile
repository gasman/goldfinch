#
# Wahey, a messed up makefile for building libraries!
# $Id:$
#

AFILES = \
	read_block.asm

all: ../../lib/block_device.lib

../../lib/block_device.lib: $(AFILES) block_device.lst
	z80asm -x../../lib/block_device @block_device.lst

clean:
	rm -f *.o* *.sym *.map *.err zcc_opt.def *.i

