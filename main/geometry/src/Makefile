
sinclude Makeconf

# assumptions to make if not using ./configure script
ifndef OCTAVE_FORGE
	MKOCTFILE=mkoctfile -s -v
	HAVE_QHULL=1
	NEED_QHULL_VERSION=0
endif

ifeq ($(NEED_QHULL_VERSION),yes)
	DEFS=-DNEED_QHULL_VERSION
endif
%.oct: %.cc ; $(MKOCTFILE) $(DEFS) -lqhull $<

ifeq ($(HAVE_QHULL),yes)
all: tsearch.oct convhulln.oct __voronoi__.oct delaunayn.oct
else
all:
endif

clean: ; -$(RM) *.o core octave-core *.oct *~
