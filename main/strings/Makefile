sinclude ../../Makeconf

PROGS=regexp.oct
ifeq ($(HAVE_PCRE),yes)
  PROGS:=$PROGS pcregexp.oct
endif

all: $(PROGS)

pcregexp.oct: pcregexp.cc
	$(MKOCTFILE) $< -lpcre

clean: ; -$(RM) *.o core octave-core *.oct *~
