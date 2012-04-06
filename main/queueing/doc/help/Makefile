DISTFILES=$(wildcard *.texi)

ALL:
	octave -p ../../inst/ -q ../grabhelp.m ../../inst/ && touch DONE

dist:
	ln $(DISTFILES) ../../`cat ../../fname`/doc/help

clean:
	\rm -f *.texi *~ DONE

distclean: clean

