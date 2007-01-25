all: $(wildcard *.cc)

%.oct: %.cc
	mkoctfile $<

clean: ; -rm *.o core octave-core *.oct *~
