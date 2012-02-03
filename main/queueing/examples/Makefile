DISTFILES=grabdemo.m Makefile

.PHONY: clean distclean check

ALL: done

done:
	octave -q grabdemo.m && touch done

dist:
	ln $(DISTFILES) ../`cat ../fname`/examples/

clean:
	\rm -f demo_*.m *~ done

distclean: clean


