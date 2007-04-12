PROGS = $(patsubst %.cc,%.oct,$(wildcard *.cc))

all: $(PROGS)

$(PROGS): Makefile

%.oct: %.cc
	mkoctfile $<

clean: ; -rm *.o core octave-core *.oct *~
