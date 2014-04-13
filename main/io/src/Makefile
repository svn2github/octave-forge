all: csvexplode.oct csv2cell.oct csvconcat.oct cell2csv.oct xmlread.oct __num2char__.mex __char2num__.mex

## Compiling these function does produces warnings but seems there is no one
## to fix them so we do not enable Wall. Just for reference, here they are
## xmltree_read.l: In function ‘xml_lex’:
## xmltree_read.l:407: warning: operation on ‘pcdata’ may be undefined
## xmltree_read.l:492: warning: operation on ‘pcdata’ may be undefined
## xmltree_read.l:627: warning: operation on ‘pcdata’ may be undefined
## xmltree_read.l:673: warning: operation on ‘pcdata’ may be undefined
## xmltree_read.l:726: warning: operation on ‘pcdata’ may be undefined
## xmltree_read.act: At top level:
## xmltree_read.l:150: warning: ‘bufferliteral’ defined but not used
## xmltree_read.l:1221: warning: ‘input’ defined but not used
#MKOCTFILE = mkoctfile -Wall
MKOCTFILE = mkoctfile

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

__num2char__.mex: __num2char__.c
	$(MKOCTFILE) --mex $^

__char2num__.mex: __char2num__.c
	$(MKOCTFILE) --mex $^
  
%.oct: %.cc
	$(MKOCTFILE) $<

clean:
	rm -f *.o octave-core core *.oct *.mex *~
