include ../../Makeconf

ifdef HAVE_LIB_TERMCAP
	TERM_LIB=-ltermcap
endif


all:	dispatch.oct waitbar.oct listen.oct xmlread.oct \
	csvexplode.oct csv2cell.oct csvconcat.oct cell2csv.oct

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
	$(MKOCTFILE) $(MISCDEFS) -c $<

ifdef FLEXML
xmltree_read.l: xmltree_read.act octave.dtd
	 $(FLEXML) -A -a $^
endif

ifdef FLEX
xmltree_read.c: xmltree_read.l
	$(FLEX) -B -Pxml_ -o$@ $<
endif

xmltree_read.o: xmltree_read.c xmltree_read.h
	$(MKOCTFILE) $(MISCDEFS) -c $<

xmlread.o: xmlread.cc xmltree_read.h xmltree.h
	$(MKOCTFILE) $(MISCDEFS) -c $<

xmlread.oct: xmlread.o xmltree_read.o xmltree.o
	$(MKOCTFILE) $^

csvexplode.oct: csvexplode.cc
	$(MKOCTFILE) $(MISCDEFS) $<

csv2cell.oct: csv2cell.cc
	$(MKOCTFILE) $(MISCDEFS) $<

csvconcat.oct: csvconcat.cc
	$(MKOCTFILE) $(MISCDEFS) $<

cell2csv.oct: cell2csv.cc
	$(MKOCTFILE) $(MISCDEFS) $<

clean: ; -$(RM) *.o octave-core core *.oct *~
