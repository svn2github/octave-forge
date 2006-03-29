sinclude ../../Makeconf

ifeq ($(HAVE_PCRE),yes)
  PROGS:=pcregexp.oct
endif

ifeq ($(HAVE_PCRE_CONFIG),yes)
  PCRE_OPTIONS=$(shell pcre-config --cflags --libs)
else
  PCRE_OPTIONS=-lpcre
endif

all: $(PROGS)

pcregexp.oct: pcregexp.cc
	$(MKOCTFILE) $< $(PCRE_OPTIONS)

clean: ; -$(RM) *.o core octave-core *.oct *~ $(t2.9.4)
