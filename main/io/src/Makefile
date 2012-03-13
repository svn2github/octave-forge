all: csvexplode.oct csv2cell.oct csvconcat.oct cell2csv.oct xmlread.oct

MKOCTFILE = mkoctfile -Wall

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

xmltree.o: xmltree.c xmltree.h
	$(MKOCTFILE) -c $<

xmltree_read.o: xmltree_read.c xmltree_read.h
	$(MKOCTFILE) -c $<

xmlread.o: xmlread.cc xmltree_read.h xmltree.h
	$(MKOCTFILE) -c $<

xmlread.oct: xmlread.o xmltree_read.o xmltree.o
	$(MKOCTFILE) $^

%.oct: %.cc
	$(MKOCTFILE) $<

clean:
	rm -f *.o octave-core core *.oct *~
