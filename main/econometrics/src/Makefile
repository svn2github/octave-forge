all: __kernel_weights.oct

%.oct: %.cc
	mkoctfile -s $<

clean:
	-rm *.o core octave-core *.oct *~
