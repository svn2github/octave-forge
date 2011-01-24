ifndef MKOCTFILE
MKOCTFILE := mkoctfile
endif

all: __bfgsmin.oct numgradient.oct numhessian.oct samin.oct

%.oct: %.cc
	$(MKOCTFILE) -s $<

clean:
	-rm *.o core octave-core *.oct *~
