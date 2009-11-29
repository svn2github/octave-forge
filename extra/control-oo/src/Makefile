all: slab08nd.oct slab13dd.oct

%.oct: %.cc
	mkoctfile -s $<

clean:
	-rm *.o core octave-core *.oct *~
