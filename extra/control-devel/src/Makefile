# LAPACK_LIBS := $(shell mkoctfile -p LAPACK_LIBS)
# BLAS_LIBS := $(shell mkoctfile -p BLAS_LIBS)
FLIBS := $(shell mkoctfile -p FLIBS)

all: devel_slicot_functions.oct

# unpack and compile SLICOT library
slicotlibrary.a: slicot.tar.gz
	tar -xzf slicot.tar.gz
	mv slicot/src/*.f .
	mv slicot/src_aux/*.f .
	mkoctfile -c *.f
	ar -rc slicotlibrary.a *.o
	rm -rf *.o *.f slicot

lapacklibrary.a: lapack-3.4.1.tgz
	tar -xzf lapack-3.4.1.tgz
	mv lapack-3.4.1/BLAS/SRC/*.f .
	mv lapack-3.4.1/INSTALL/*.f .
	mv lapack-3.4.1/SRC/*.f .
	mkoctfile -c *.f
	ar -rc lapacklibrary.a *.o
	rm -rf *.o *.f lapack-3.4.1

# slicot functions
devel_slicot_functions.oct: devel_slicot_functions.cc slicotlibrary.a lapacklibrary.a
	mkoctfile devel_slicot_functions.cc common.cc slicotlibrary.a lapacklibrary.a \
              ${FLIBS}

clean:
	rm -rf *.o core octave-core *.oct *~ *.f slicot lapack-3.4.1

realclean: clean
	rm -rf *.a