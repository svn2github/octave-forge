sinclude ../../Makeconf

ifeq (,$(findstring powerpc-apple-darwin,$(canonical_host_type)))
none:
	touch NOINSTALL
endif

all: sndplay
	echo extra/MacOSX will be installed

## Using explicit -ObjC flag since .cc is used to trick PKG_ADD to pick up the file. 
sndplay: OFSndPLay.cc
	mkdir -p bin
	CC -ObjC -o bin/ofsndplay OFSndPLay.cc -framework Cocoa

clean:
	-$(RM) -r bin
