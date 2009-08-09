all: libs examples

libs:
	cd libsrc && make && cd ..

examples: libs
	cd examples && make && cd ..

clean:
	cd examples ; make clean ; cd ..
	cd lib ; make clean ; cd ..
	cd libsrc ; make clean ; cd ..
