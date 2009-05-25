sector_dump.tap: loader.bas.tap sector_dump.bin.tap
	cat loader.bas.tap sector_dump.bin.tap > sector_dump.tap

sector_dump.bin.tap: sector_dump.bin
	bintap sector_dump.bin sector_dump.bin.tap sectordump 32768

loader.bas.tap: loader.bas
	zmakebas -a 10 -n loader -o loader.bas.tap loader.bas

sector_dump.bin: libs include/divide.h include/block_device.h sector_dump.c
	zcc +zx sector_dump.c -o sector_dump.bin -lndos -Ca-ilib/divide -Ca-ilib/block_device

libs:
	cd libsrc && make && cd ..

clean:
	cd lib ; make clean ; cd ..
	cd libsrc ; make clean ; cd ..
	rm -f *.o* *.sym *.map *.err zcc_opt.def *.i *.tap *.bin
