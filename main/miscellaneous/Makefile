include ../../Makeconf

ifdef HAVE_LIB_TERMCAP
	TERM_LIB=-ltermcap
endif


all:	dispatch.oct waitbar.oct listen.oct xmlread.oct

waitbar.oct:	waitbar.cc
	$(MKOCTFILE) $(MISCDEFS) waitbar.cc $(TERM_LIB)

dispatch.oct: dispatch.cc
	$(MKOCTFILE) $(MISCDEFS) $(TYPEID_HAS_CLASS) dispatch.cc

listen.oct: listen.o listencanfork.o
	$(MKOCTFILE) listen.o listencanfork.o

listen.o: listen.cc
	$(MKOCTFILE) -c $(MISCDEFS) listen.cc

listencanfork.o: listencanfork.c
	$(MKOCTFILE) -c listencanfork.c

xmltree.o: xmltree.c xmltree.h
	$(CC) -c $< -o $@

ifdef FLEXML
xmltree_read.l: xmltree_read.act octave.dtd
	 $(FLEXML) -A -a $^
endif

ifdef FLEX
xmltree_read.c: xmltree_read.l
	$(FLEX) -B  -o$@ $<
endif

xmltree_read.o: xmltree_read.c xmltree_read.h
	$(CC) -c $< -o $@

xmlread.o: xmlread.cc xmltree_read.h xmltree.h
	$(MKOCTFILE) -c $< -o $@

xmlread.oct: xmlread.o xmltree_read.o xmltree.o
	$(MKOCTFILE) $^ -o $@

clean: ; -$(RM) *.o octave-core core *.oct *~
