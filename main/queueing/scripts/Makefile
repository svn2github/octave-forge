DISTFILES=gethelp.cc munge-texi.cc Makefile mkdoc pmva.y pmva.l test.pmva

.PHONY: clean

ALL: gethelp munge-texi

gethelp: gethelp.cc

munge-texi: munge-texi.cc

dist:
	ln $(DISTFILES) ../`cat ../fname`/scripts/

clean:
	\rm -f *~ *.o y.tab.* lex.yy.*

distclean: clean
	\rm -f gethelp munge-texi

pmva: y.tab.o lex.yy.o
	$(CC) y.tab.o lex.yy.o -o $@

lex.yy.o: lex.yy.c y.tab.h

y.tab.o: y.tab.c y.tab.h pmva.h

y.tab.c y.tab.h: pmva.y
	bison -y -l -d $<

lex.yy.c: pmva.l
	flex -L $<
