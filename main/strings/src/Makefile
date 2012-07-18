MKOCTFILE = mkoctfile -Wall

REGEX_LIBS := $(shell  grep "\#define OCTAVE_CONF_REGEX_LIBS"  $(shell  $(MKOCTFILE) -p OCTINCLUDEDIR)/oct-conf.h | sed 's/^.*LIBS //;s/"//g'  )

all: pcregexp.oct

%.oct: %.cc
	$(MKOCTFILE) $<  -o $@ $(REGEX_LIBS)

clean:
	rm -f *.o octave-core core *.oct *~
