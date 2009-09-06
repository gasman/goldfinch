installer.tap: installer.bas.tap installer.bin.tap
	cat installer.bas.tap installer.bin.tap > installer.tap

installer.bin: firmware.bin installer.asm
	z80asm -b installer.asm

installer.bin.tap: installer.bin
	bintap installer.bin installer.bin.tap installer1 24576 > /dev/null

installer.bas.tap: installer.bas
	zmakebas -a 10 -n installer -o installer.bas.tap installer.bas

AFILES = \
	page_0_hooks.asm \
	nmi.asm \
	interrupt.asm \
	exit.asm \
	tape_load.asm \
	tape_save.asm \
	startup.asm \
	firmware_data.asm \
	clear_screen.asm \
	print_dir.asm \
	dir_handler.asm \
	scr_handler.asm
	
OBJECTS = $(AFILES:.asm=.obj)

firmware.bin: firmware.gary ${OBJECTS}
	ruby ../../bin/gary/gary.rb firmware.gary firmware.bin

page_0_hooks.obj: page_0_hooks.asm
	z80asm page_0_hooks.asm 
nmi.obj: nmi.asm
	z80asm nmi.asm 
exit.obj: exit.asm
	z80asm exit.asm 
tape_load.obj: tape_load.asm
	z80asm tape_load.asm 
tape_save.obj: tape_save.asm
	z80asm tape_save.asm 
startup.obj: startup.asm
	z80asm startup.asm 
firmware_data.obj: firmware_data.asm
	z80asm firmware_data.asm 
clear_screen.obj: clear_screen.asm
	z80asm clear_screen.asm 
print_dir.obj: print_dir.asm
	z80asm print_dir.asm 
interrupt.obj: interrupt.asm
	z80asm interrupt.asm 
dir_handler.obj: dir_handler.asm
	z80asm dir_handler.asm 
scr_handler.obj: scr_handler.asm
	z80asm scr_handler.asm

clean:
	rm -f *.o* *.sym *.map *.err zcc_opt.def *.i *.tap *.bin
	