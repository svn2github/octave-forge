ifndef MKOCTFILE
MKOCTFILE := mkoctfile
endif

LAPACK_LIBS := $(shell mkoctfile -p LAPACK_LIBS)

all: __bfgsmin.oct numgradient.oct numhessian.oct samin.oct __disna_optim__.oct

%.oct: %.cc
	$(MKOCTFILE) -s $< ${LAPACK_LIBS}

clean:
	-rm *.o core octave-core *.oct *~
