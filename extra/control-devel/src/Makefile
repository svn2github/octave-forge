MKOCTFILE ?= mkoctfile

ifndef LAPACK_LIBS
LAPACK_LIBS := $(shell $(MKOCTFILE) -p LAPACK_LIBS)
endif
ifndef BLAS_LIBS
BLAS_LIBS := $(shell $(MKOCTFILE) -p BLAS_LIBS)
endif
ifndef FLIBS
FLIBS := $(shell $(MKOCTFILE) -p FLIBS)
endif
LFLAGS := $(shell $(MKOCTFILE) -p LFLAGS) $(LAPACK_LIBS) $(BLAS_LIBS) $(FLIBS)

all: devel_slicot_functions.oct \
     is_matrix.oct

# unpack and compile SLICOT library
slicotlibrary.a: slicot.tar.gz
	tar -xzf slicot.tar.gz
	mv slicot/src/*.f .
	mv slicot/src_aux/*.f .
	$(MKOCTFILE) -c *.f
	ar -rc slicotlibrary.a *.o
	rm -rf *.o *.f slicot

# slicot functions
devel_slicot_functions.oct: devel_slicot_functions.cc slicotlibrary.a
	LFLAGS="$(LFLAGS)" \
    $(MKOCTFILE) devel_slicot_functions.cc common.cc slicotlibrary.a

# helpers
is_matrix.oct: is_matrix.cc
	$(MKOCTFILE) is_matrix.cc

clean:
	rm -rf *.o core octave-core *.oct *~ *.f slicot

realclean: clean
	rm -rf *.a