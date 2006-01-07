sinclude ../../Makeconf

## Change this to the location of mkoctfile for your version of
## octave linked against pthreads (see README).
MKOCTFILE ?= mkoctfile

## Compile and link opts --- set as appropriate for your system
TCL_OPTS = -I/usr/include/tcl8.4 -ltcl8.4 -ltk8.4 -lpthread
VTK_OPTS = -DHAVE_VTK -lvtkCommon -lvtkGraphics -lvtkImaging -lGL
BLT_OPTS = -DHAVE_BLT -lBLT

## The remainder of this file should not need changing
OPTS  = $(TCL_OPTS) $(BLT_OPTS) $(VTK_OPTS)
LINKS = $(patsubst %,%$(OCTLINK), tk_loop tk_end tk_cmd)

ifdef TCL_OPTS
all: tk_interp.oct $(LINKS)
else
all: ; @echo No Tcl/TK: tk_octave is not being built
endif

tk_interp.oct: tk_interp.cc
	$(MKOCTFILE) -v $^ -o $@ $(OPTS)

$(LINKS):
	-$(RM) $@
	$(MKOCTLINK) tk_interp.oct $@

clean: ; -$(RM) core octave-core *.o *.oct *~

