sinclude ../../Makeconf

ifdef HAVE_LIB_TERMCAP
	TERM_LIB=-ltermcap
endif

DISPATCH_LINK=dispatch_help.oct builtin.oct
t2.1.58=inline.m
t2.9.0=dispatch.oct $(DISPATCH_LINK)
DEPRECIATED_TARGETS=$($(word 2, $(sort t$(OCTAVE_VERSION) t2.1.58))) \
	$($(word 2, $(sort t$(OCTAVE_VERSION) t2.9.0)))
TARGETS=waitbar.oct listen.oct xmlread.oct \
	csvexplode.oct csv2cell.oct csvconcat.oct cell2csv.oct \
	$(DEPRECIATED_TARGETS)

all:	$(TARGETS)

$(DISPATCH_LINK):
	-$(RM) $@
	$(LN_S) dispatch.oct $@

waitbar.oct:	waitbar.cc
	$(MKOCTFILE) $(MISCDEFS) waitbar.cc $(TERM_LIB)

dispatch.oct: dispatch.cc
	$(MKOCTFILE) $(MISCDEFS) $(TYPEID_HAS_CLASS) dispatch.cc

listen.oct: listen.o listencanfork.o stringmatch.o
	$(MKOCTFILE) listen.o listencanfork.o stringmatch.o

listen.o: listen.cc
	$(MKOCTFILE) -c $(MISCDEFS) listen.cc

listencanfork.o: listencanfork.c
	$(MKOCTFILE) -c listencanfork.c

stringmatch.o: stringmatch.c
	$(MKOCTFILE) -c stringmatch.c

xmltree.o: xmltree.c xmltree.h
	$(MKOCTFILE) $(MISCDEFS) -c $<

ifdef FLEXML
# flexml is a dead project.  It requires flex 2.5.4a-6  (flex-old on Debian).
# Further, we have modified the resulting xmltree_read.c by hand, changing
# all occurrences of yy to xml_ and YY to XML_. Some other changes have be
# mode so the ouput of flexml won't be as correct as the actual committed C
# file
xmltree_read.l: xmltree_read.act octave.dtd
	 $(FLEXML) -A -a $^
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

clean: ; -$(RM) *.o octave-core core *.oct *~ $(t2.1.58)

%.m : %.m.in
	-$(INSTALL) $< $@
