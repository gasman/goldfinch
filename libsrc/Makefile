LIBRARIES = \
	divide \
	block_device \
	buffer \
	zzzfs \
	trdos \
	fatfs \
	lowio \
	asciiprint \
	keyscan \
	dirtywindow \
	input \
	tap

all:
	for l in $(LIBRARIES); do \
		cd $$l ; make ; cd ..; \
	done

clean:
	for l in $(LIBRARIES); do \
		cd $$l ; make clean ; cd ..; \
	done
