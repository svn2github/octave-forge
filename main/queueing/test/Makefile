DISTFILES=Makefile fntests.m

.PHONY: check dist clean

ALL:

check:
	cd ../inst && octave -qf ../test/fntests.m

dist:
	ln $(DISTFILES) ../`cat ../fname`/test/

clean:
	\rm -f *~ fntests.log

distclean: clean
