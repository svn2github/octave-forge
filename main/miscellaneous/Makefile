include ../../Makeconf

ifdef HAVE_LIB_TERMCAP
	TERM_LIB=-ltermcap
endif


all:	dispatch.oct waitbar.oct listen.oct

waitbar.oct:	waitbar.cc
	$(MKOCTFILE) $(MISCDEFS) waitbar.cc $(TERM_LIB)

dispatch.oct: dispatch.cc
	$(MKOCTFILE) $(TYPEID_HAS_CLASS) dispatch.cc

listen.oct: listen.o listencanfork.o
	$(MKOCTFILE) listen.o listencanfork.o

listen.o: listen.cc
	$(MKOCTFILE) -c $(MISCDEFS) listen.cc

listencanfork.o: listencanfork.c
	$(MKOCTFILE) -c listencanfork.c

clean: ; -$(RM) *.o octave-core core *.oct *~
