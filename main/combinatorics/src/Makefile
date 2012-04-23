MKOCTFILE = /home/octave-admin/bin-3.6.1/bin/mkoctfile -Wall

PROGS = $(patsubst %.cc,%.oct,$(wildcard *.cc))

all: $(PROGS)

%.oct: %.cc
	$(MKOCTFILE) $<

clean:
	rm -f *.o octave-core core *.oct *~
