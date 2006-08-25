all: $(wildcard *.cc)

%.oct: %.cc
	mkoctfile $<

clean: ; -$(RM) *.o core octave-core *.oct *~
