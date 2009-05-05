PROGS = $(patsubst %.cpp,%.mex,$(wildcard *.cpp))

all: $(PROGS)

$(PROGS): Makefile

%.oct: %.cc
	mkoctfile $<

%.mex: %.cpp
	mkoctfile --mex $<

clean: ; -$(RM) *.o core octave-core *.oct *~ *.mex
