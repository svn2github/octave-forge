.PHONY: clean check dist
DISTFILES=$(wildcard *.m)

ALL:

clean:
	\rm -f *~

distclean: clean

dist:
	ln $(DISTFILES) ../../`cat ../../fname`/inst/private/
