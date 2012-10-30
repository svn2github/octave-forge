VERSIONNUM=2.0.0
VERSIONDATE="2012-10-XX"
PROGNAME=queueing

DISTNAME=$(PROGNAME)-$(VERSIONNUM)
SUBDIRS=inst doc test devel
DISTFILES=COPYING NEWS DESCRIPTION
DISTSUBDIRS=inst doc
OCTAVE=octave

.PHONY: clean check

ALL: DESCRIPTION doc/conf.texi
	for d in $(SUBDIRS); do \
		$(MAKE) -C $$d ALL; \
	done

doc/conf.texi:
	\rm -f doc/conf.texi
	echo "@set VERSION $(VERSIONNUM)" > doc/conf.texi
	echo "@set VERSIONDATE $(VERSIONDATE)" >> doc/conf.texi
	echo "@c @set top_srcdir " `pwd` >> doc/conf.texi

DESCRIPTION: DESCRIPTION.in
	cat DESCRIPTION.in | \
	sed "s/PROGNAME/$(PROGNAME)/g" | \
	sed "s/VERSIONNUM/$(VERSIONNUM)/g" | \
	sed "s/VERSIONDATE/$(VERSIONDATE)/g" > DESCRIPTION

check:
	$(MAKE) -C test check

clean:
	for d in $(SUBDIRS); do \
		$(MAKE) -C $$d $(MAKECMDGOALS); \
	done
	\rm -r -f *~ $(DISTNAME).tar.gz $(DISTNAME).tar.gz.uue $(PROGNAME) $(PROGNAME)-html.tar.gz $(PROGNAME)-html.tar.gz.uue $(PROGNAME)-html

distclean: clean
	for d in $(SUBDIRS); do \
		$(MAKE) -C $$d $(MAKECMDGOALS); \
	done
	\rm -r -f doc/conf.texi fname DESCRIPTION $(PROGNAME)-html

$(DISTNAME).tar.gz:
	\rm -r -f $(PROGNAME) fname
	echo "$(PROGNAME)" > fname
	mkdir $(PROGNAME)
	for d in $(DISTSUBDIRS); do \
		mkdir -p $(PROGNAME)/$$d; \
		$(MAKE) -C $$d $(MAKECMDGOALS); \
	done
	ln $(DISTFILES) $(PROGNAME)/
	tar cfz $(DISTNAME).tar.gz $(PROGNAME)/
	uuencode $(DISTNAME).tar.gz < $(DISTNAME).tar.gz > $(DISTNAME).tar.gz.uue

$(PROGNAME)-html.tar.gz:
	~/src/octave-3.6.1/run-octave -q --eval "pkg install -local $(DISTNAME).tar.gz; pkg load queueing; generate_package_html ('queueing', 'queueing-html', 'octave-forge'); pkg uninstall $(PROGNAME)"
	tar cfz $(PROGNAME)-html.tar.gz $(PROGNAME)-html
	uuencode $(PROGNAME)-html.tar.gz < $(PROGNAME)-html.tar.gz > $(PROGNAME)-html.tar.gz.uue

dist: ALL $(DISTNAME).tar.gz $(PROGNAME)-html.tar.gz




