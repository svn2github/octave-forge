sinclude ../../Makeconf

PROGS=regexp.oct
ifeq ($(HAVE_PCRE),yes)
  PROGS:=$(PROGS) pcregexp.oct
endif

ifeq ($(HAVE_PCRE_CONFIG),yes)
  PCRE_OPTIONS=$(shell pcre-config --cflags --libs)
else
  PCRE_OPTIONS=-lpcre
endif

all: $(PROGS)

regexp.oct: regexp.cc
	$(MKOCTFILE) $< $(REGEX_LIB)

pcregexp.oct: pcregexp.cc
	$(MKOCTFILE) $< $(PCRE_OPTIONS)

clean: ; -$(RM) *.o core octave-core *.oct *~
