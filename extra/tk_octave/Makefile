sinclude ../../Makeconf

## Change this to the location of mkoctfile for your version of
## octave linked against pthreads (see README).
ifndef MKOCTFILE
MKOCTFILE=mkoctfile-pthreads
HAVE_TCLTK=1
endif

VTK_OPTS = -DHAVE_VTK -lVTKCommon -lVTKGraphics -lVTKImaging -lGL
BLT_OPTS = -DHAVE_BLT -lBLT

## Include either or both VTK_OPTS and BLT_OPTS if you have VTK/BLT installed
ifdef HAVE_BLT
OPTS += $(BLT_OPTS)
endif
ifdef HAVE_VTK
OPTS += $(VTK_OPTS)
endif

## The remainder of this file should not need changing
LIBS = -ltcl -ltk -lpthread

ifdef HAVE_TCLTK
all: tk_interp.oct
else
all:
	@echo No Tcl/TK: tk_octave is not being built
endif

tk_interp.oct: tk_interp.cc
	$(MKOCTFILE) -v $^ -o $@ $(OPTS) $(LIBS)

clean:
	-$(RM) core octave-core *.o *.oct *~

