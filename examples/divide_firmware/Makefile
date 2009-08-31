installer.tap: installer.bas.tap installer.bin.tap
	cat installer.bas.tap installer.bin.tap > installer.tap

installer.bin: firmware.bin installer.asm
	z80asm -b installer.asm

installer.bin.tap: installer.bin
	bintap installer.bin installer.bin.tap installer1 24576 > /dev/null

installer.bas.tap: installer.bas
	zmakebas -a 10 -n installer -o installer.bas.tap installer.bas

firmware.bin: firmware.gary startup.obj exit.obj tape_load.obj tape_save.obj
	ruby ../../bin/gary/gary.rb firmware.gary firmware.bin

startup.obj: startup.asm
	z80asm startup.asm 
exit.obj: exit.asm
	z80asm exit.asm 
tape_load.obj: tape_load.asm
	z80asm tape_load.asm 
tape_save.obj: tape_save.asm
	z80asm tape_save.asm 

clean:
	rm -f *.o* *.sym *.map *.err zcc_opt.def *.i *.tap *.bin
	