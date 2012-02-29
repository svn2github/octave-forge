LAPACK_LIBS := $(shell mkoctfile -p LAPACK_LIBS)
BLAS_LIBS := $(shell mkoctfile -p BLAS_LIBS)
FLIBS := $(shell mkoctfile -p FLIBS)

all: devel_slicot_functions.oct

# unpack and compile SLICOT library
slicotlibrary.a: slicot.tar.gz
	tar -xzf slicot.tar.gz
	mv slicot/src/*.f .
	mv slicot/src_aux/*.f .
	mkoctfile -c *.f
	ar -r slicotlibrary.a *.o
	rm -rf *.o *.f slicot

# slicot functions
devel_slicot_functions.oct: devel_slicot_functions.cc slicotlibrary.a
	mkoctfile devel_slicot_functions.cc common.cc slicotlibrary.a \
              ${LAPACK_LIBS} ${BLAS_LIBS} ${FLIBS}

clean:
	rm -rf *.o core octave-core *.oct *~ *.f slicot

realclean: clean
	rm -rf *.a