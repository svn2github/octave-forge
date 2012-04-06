DISTFILES=$(wildcard *.texi)

ALL:
	octave -p ../../inst/ -q ../grabdemo.m ../../inst/ && touch DONE

dist:
	ln $(DISTFILES) ../../`cat ../../fname`/doc/demos

clean:
	\rm -f *.texi *~ DONE

distclean: clean

