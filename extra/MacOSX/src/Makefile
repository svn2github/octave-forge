sinclude ./Makeconf

ifeq (,$(findstring powerpc-apple-darwin,$(canonical_host_type)))

all:
	@echo "Not building MacOS specific functions"

else

all: ../bin/ofsndplay ../inst/image.m
	echo extra/MacOSX will be installed

## Using explicit -ObjC flag since .cc is used to trick PKG_ADD to pick up the file. 
../bin/ofsndplay: OFSndPlay.cc
	mkdir -p bin
	$(CC) -ObjC -o bin/ofsndplay OFSndPlay.cc -framework Cocoa

## Trick installation of image.m by keeping it in src and only copying to
## ../inst if needed
../inst/image.m.in:
	cp image.m.in ../inst/image.m

endif
