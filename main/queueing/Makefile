VERSIONNUM=1.X.0
VERSIONDATE="2012-02-XX"
PROGNAME=queueing

DISTNAME=$(PROGNAME)-$(VERSIONNUM)
SUBDIRS=inst scripts examples doc test devel
DISTFILES=COPYING NEWS DESCRIPTION
DISTSUBDIRS=inst doc

.PHONY: clean check

ALL: DESCRIPTION doc/conf.texi
	for d in $(SUBDIRS); do \
		$(MAKE) -C $$d ALL; \
	done

doc/conf.texi:
	\rm -f doc/conf.texi
	echo "@set VERSION $(VERSIONNUM)" > doc/conf.texi
	echo "@set VERSIONDATE $(VERSIONDATE)" >> doc/conf.texi
	echo "@set top_srcdir " `pwd` >> doc/conf.texi

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
	\rm -r -f *~ $(DISTNAME).tar.gz $(DISTNAME).tar.gz.uue $(PROGNAME)

distclean: clean
	for d in $(SUBDIRS); do \
		$(MAKE) -C $$d $(MAKECMDGOALS); \
	done
	\rm -r -f doc/conf.texi fname DESCRIPTION

dist: ALL
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

