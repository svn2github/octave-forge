sinclude Makeconf

ifdef HAVE_LIB_TERMCAP
	TERM_LIB=-ltermcap
endif

TARGETS=text_waitbar.oct $(LISTEN) cell2cell.oct sample.oct partarray.oct

all:	$(TARGETS)

text_waitbar.oct: text_waitbar.cc
	$(MKOCTFILE) $(MISCDEFS) text_waitbar.cc $(TERM_LIB)

server.oct: server.o listencanfork.o stringmatch.o
	$(MKOCTFILE) server.o listencanfork.o stringmatch.o

server.o: server.cc
	$(MKOCTFILE) -c $(MISCDEFS) server.cc

listencanfork.o: listencanfork.c
	$(MKOCTFILE) -c listencanfork.c

stringmatch.o: stringmatch.c
	$(MKOCTFILE) -c stringmatch.c

cell2cell.oct: cell2cell.cc
	$(MKOCTFILE) $(MISCDEFS) $<

partarray.oct: partarray.cc
	$(MKOCTFILE) $(MISCDEFS) $<

sample.oct: sample.cc
	$(MKOCTFILE) $(MISCDEFS) $<

clean: ; -$(RM) *.o octave-core core *.oct *~ $(t2.1.58)
