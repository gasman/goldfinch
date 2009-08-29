screenbrowser.tap: loader.bas.tap screenbrowser.bin.tap
	cat loader.bas.tap screenbrowser.bin.tap > screenbrowser.tap

screenbrowser.bin.tap: screenbrowser.bin
	bintap screenbrowser.bin screenbrowser.bin.tap screenbrws 32768 > /dev/null

loader.bas.tap: loader.bas
	zmakebas -a 10 -n loader -o loader.bas.tap loader.bas

screenbrowser.bin: screenbrowser.asm
	z80asm -b -i../../lib/buffer -i../../lib/lowio -i../../lib/fatfs -i../../lib/divide -i../../lib/block_device screenbrowser

clean:
	rm -f *.o* *.sym *.map *.err zcc_opt.def *.i *.tap *.bin
	