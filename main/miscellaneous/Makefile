include ../../Makeconf

ifdef HAVE_LIB_TERMCAP
	TERM_LIB=-ltermcap
endif


all:	dispatch.oct waitbar.oct listen.oct

waitbar.oct:	waitbar.cc
	$(MKOCTFILE) $(MISCDEFS) waitbar.cc $(TERM_LIB)

listen.oct: listen.cc
	$(MKOCTFILE) $(MISCDEFS) listen.cc

clean: ; -$(RM) *.o octave-core core *.oct *~
