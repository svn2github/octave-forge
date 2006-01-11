sinclude ../../Makeconf

t2.9.4=regexp.oct str2double.m strmatch.m strcmpi.m
DEPRECIATED_TARGETS=$($(word 2, $(sort t$(OCTAVE_VERSION) t2.9.4)))
PROGS=$(DEPRECIATED_TARGETS)
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

clean: ; -$(RM) *.o core octave-core *.oct *~ $(t2.9.4)

%.m : %.m.in
	-$(INSTALL) $< $@
