MKOCTFILE ?= mkoctfile

LAPACK_LIBS ?= $(shell $(MKOCTFILE) -p LAPACK_LIBS)
# reported necessary for Apple's VecLib framework by Carlo de Falco
# <carlo.defalco@gmail.com>
BLAS_LIBS ?= $(shell $(MKOCTFILE) -p BLAS_LIBS)

# Passing LFLAGS, supplemented with LAPACK_LIBS and BLAS_LIBS, in the
# environment to mkoctfile is prefered over passing LAPACK_LIBS and
# BLAS_LIBS in mkoctfiles commandline due to mkoctfiles difficulties
# with non-standard flags on some systems (e.g. -framework ... on
# Apple)
LFLAGS := $(shell $(MKOCTFILE) -p LFLAGS) $(LAPACK_LIBS) $(BLAS_LIBS)

all: __bfgsmin.oct numgradient.oct numhessian.oct samin.oct __disna_optim__.oct

%.oct: %.cc
	LFLAGS="$(LFLAGS)" $(MKOCTFILE) -s $<

clean:
	$(RM) *.o core octave-core *.oct *~
