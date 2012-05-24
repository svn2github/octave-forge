MKOCTFILE ?= mkoctfile

LAPACK_LIBS := $(shell $(MKOCTFILE) -p LAPACK_LIBS)
# reported necessary for Apple's VecLib framework by Carlo de Falco
# <carlo.defalco@gmail.com>
BLAS_LIBS := $(shell $(MKOCTFILE) -p BLAS_LIBS)

all: __bfgsmin.oct numgradient.oct numhessian.oct samin.oct __disna_optim__.oct

%.oct: %.cc
	$(MKOCTFILE) -s $< $(LAPACK_LIBS) $(BLAS_LIBS)

clean:
	$(RM) *.o core octave-core *.oct *~
