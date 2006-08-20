all: leval.oct __bfgsmin.oct celleval.oct numgradient.oct numhessian.oct samin.oct

%.oct: %.cc
	mkoctfile -s $<

clean:
	rm *.o core octave-core *.oct *~
