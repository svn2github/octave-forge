all: verletstep.oct

%.oct: %.cc
	mkoctfile -Wall $<

clean:
	rm -f *.o octave-core core *.oct *~
