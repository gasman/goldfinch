all: simple_io.tap sector_dump.tap trdos.tap fatfs_dir.tap screenbrowser0 fatfs_write.tap

sector_dump.tap: loader.bas.tap sector_dump.bin.tap
	cat loader.bas.tap sector_dump.bin.tap > sector_dump.tap

sector_dump.bin.tap: sector_dump.bin
	bintap sector_dump.bin sector_dump.bin.tap sectordump 32768 > /dev/null

loader.bas.tap: loader.bas
	zmakebas -a 10 -n loader -o loader.bas.tap loader.bas

sector_dump.bin: ../include/divide.h ../include/block_device.h sector_dump.c
	zcc +zx -vn sector_dump.c -o sector_dump.bin -lndos -Ca-i../lib/divide -Ca-i../lib/block_device -Ca-i../lib/buffer


simple_io.tap: loader.bas.tap simple_io.bin.tap
	cat loader.bas.tap simple_io.bin.tap > simple_io.tap

simple_io.bin.tap: simple_io.bin
	bintap simple_io.bin simple_io.bin.tap simpleio 32768 > /dev/null

simple_io.bin: ../include/divide.h ../include/block_device.h simple_io.c
	zcc +zx -vn simple_io.c -o simple_io.bin -Ca-i../lib/zzzfs -Ca-i../lib/divide -Ca-i../lib/block_device


trdos.tap: loader.bas.tap trdos.bin.tap
	cat loader.bas.tap trdos.bin.tap > trdos.tap

trdos.bin.tap: trdos.bin
	bintap trdos.bin trdos.bin.tap trdos 32768 > /dev/null

trdos.bin: ../include/divide.h ../include/block_device.h ../include/trdos.h trdos.c
	zcc +zx -vn -m trdos.c -o trdos.bin -lndos -Ca-i../lib/divide -Ca-i../lib/block_device -Ca-i../lib/trdos -Ca-i../lib/buffer -Ca-i../lib/lowio


fatfs_dir.tap: loader.bas.tap fatfs_dir.bin.tap
	cat loader.bas.tap fatfs_dir.bin.tap > fatfs_dir.tap

fatfs_dir.bin.tap: fatfs_dir.bin
	bintap fatfs_dir.bin fatfs_dir.bin.tap fatfs_dir 32768 > /dev/null

fatfs_dir.bin: ../include/fatfs.h fatfs_dir.c
	zcc +zx -vn -m fatfs_dir.c -o fatfs_dir.bin -lndos -Ca-i../lib/buffer -Ca-i../lib/divide -Ca-i../lib/block_device -Ca-i../lib/lowio -Ca-i../lib/fatfs


fatfs_write.tap: loader.bas.tap fatfs_write.bin.tap
	cat loader.bas.tap fatfs_write.bin.tap > fatfs_write.tap

fatfs_write.bin.tap: fatfs_write.bin
	bintap fatfs_write.bin fatfs_write.bin.tap fatfswrite 32768 > /dev/null

fatfs_write.bin: ../include/fatfs.h fatfs_write.c
	zcc +zx -vn -m fatfs_write.c -o fatfs_write.bin -lndos -Ca-i../lib/buffer -Ca-i../lib/divide -Ca-i../lib/block_device -Ca-i../lib/lowio -Ca-i../lib/fatfs


screenbrowser0:
	cd screenbrowser && make && cd ..

clean:
	cd screenbrowser ; make clean ; cd ..
	rm -f *.o* *.sym *.map *.err zcc_opt.def *.i *.tap *.bin
