
sinclude ../../Makeconf

# assumptions to make if not using ./configure script
ifndef OCTAVE_FORGE
	MKOCTFILE=mkoctfile -s -v
	HAVE_LIBQHULL=1
endif

%.oct: %.cc ; $(MKOCTFILE) -lqhull $<

ifdef HAVE_LIBQHULL
all: convhulln.oct __voronoi__.oct delaunayn.oct
else
all:
endif

clean: ; -$(RM) *.o core octave-core *.oct *~
