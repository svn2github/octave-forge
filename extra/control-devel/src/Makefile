LAPACK_LIBS := $(shell mkoctfile -p LAPACK_LIBS)
BLAS_LIBS := $(shell mkoctfile -p BLAS_LIBS)
FLIBS := $(shell mkoctfile -p FLIBS)

all: slab09hd.oct slab09id.oct slab09jd.oct slsb16ad.oct slsb16bd.oct \
     slsb16cd.oct slsb10yd.oct

# TODO: leading and trailing underscores for sl* functions
#       (__sl*__.oct) would be nice, but this can be an issue
#       for fortran compilers.

slicotlibrary.a: slicot.tar.gz
	tar -xzf slicot.tar.gz
	mv slicot/src/*.f .
	mv slicot/src_aux/*.f .
	mkoctfile *.f \
	${LAPACK_LIBS} ${BLAS_LIBS} ${FLIBS}
	ar -r slicotlibrary.a *.o
	rm -rf *.o *.f *.oct slicot

# balanced stochastic truncation model reduction
slab09hd.oct: slab09hd.cc slicotlibrary.a
	mkoctfile slab09hd.cc slicotlibrary.a \
              ${LAPACK_LIBS} ${BLAS_LIBS}

# balanced truncation & singular perturbation approximation model reduction
slab09id.oct: slab09id.cc slicotlibrary.a
	mkoctfile slab09id.cc slicotlibrary.a \
              ${LAPACK_LIBS} ${BLAS_LIBS}

# hankel-norm approximation model reduction
slab09jd.oct: slab09jd.cc slicotlibrary.a
	mkoctfile slab09jd.cc slicotlibrary.a \
              ${LAPACK_LIBS} ${BLAS_LIBS}

# balanced truncation & singular perturbation approximation controller reduction
slsb16ad.oct: slsb16ad.cc slicotlibrary.a
	mkoctfile slsb16ad.cc slicotlibrary.a \
              ${LAPACK_LIBS} ${BLAS_LIBS}

# coprime factorization state-feedback controller reduction
slsb16bd.oct: slsb16bd.cc slicotlibrary.a
	mkoctfile slsb16bd.cc slicotlibrary.a \
              ${LAPACK_LIBS} ${BLAS_LIBS}

# frequency-weighted coprime factorization state-feedback controller reduction
slsb16cd.oct: slsb16cd.cc slicotlibrary.a
	mkoctfile slsb16cd.cc slicotlibrary.a \
              ${LAPACK_LIBS} ${BLAS_LIBS}

# fit state-space model to frequency response data
slsb10yd.oct: slsb10yd.cc slicotlibrary.a
	mkoctfile slsb10yd.cc slicotlibrary.a \
              ${LAPACK_LIBS} ${BLAS_LIBS}

clean:
	rm -rf *.o core octave-core *.oct *~ *.a *.f slicot

realclean: clean
	rm -rf *.a
