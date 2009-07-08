LIBRARIES = \
	divide \
	block_device \
	zzzfs \
	trdos \
	fatfs

all:
	for l in $(LIBRARIES); do \
		cd $$l ; make ; cd ..; \
	done

clean:
	for l in $(LIBRARIES); do \
		cd $$l ; make clean ; cd ..; \
	done
