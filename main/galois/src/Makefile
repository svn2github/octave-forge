PROGS = $(patsubst %.cc,%.oct,$(wildcard *.cc))

all: $(PROGS)

$(PROGS): Makefile

%.oct: %.cc
	mkoctfile $<

clean: ; -$(RM) *.o core octave-core *.oct *~
