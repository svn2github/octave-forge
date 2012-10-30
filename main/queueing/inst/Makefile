.PHONY: clean check dist
DISTFILES=$(wildcard *.m) $(wildcard private/*.m) Makefile

ALL:

clean:
	\rm -f *~ fntests.log

distclean: clean

dist:
	ln $(DISTFILES) ../`cat ../fname`/inst/
