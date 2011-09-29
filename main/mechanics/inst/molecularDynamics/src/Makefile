all: verletstep.oct verletstep_boxed.oct

%.oct: %.cc
	mkoctfile -Wall $<

clean:
	rm -f *.o octave-core core *.oct *~
