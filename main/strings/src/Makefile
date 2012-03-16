MKOCTFILE = mkoctfile -Wall

all: pcregexp.oct

%.oct: %.cc
	$(MKOCTFILE) $<

clean:
	rm -f *.o octave-core core *.oct *~
