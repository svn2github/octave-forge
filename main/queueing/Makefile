VERSIONNUM=1.0.0
VERSIONDATE="2012-02-03"
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
		$(MAKE) -C $$d clean; \
	done
	\rm -r -f *~ *.tar.gz $(DISTNAME)

distclean: clean
	for d in $(SUBDIRS); do \
		$(MAKE) -C $$d distclean; \
	done
	\rm -r -f doc/conf.texi fname DESCRIPTION $(DISTNAME) $(DISTNAME).tar.gz

dist: ALL
	\rm -r -f $(DISTNAME) fname
	mkdir $(DISTNAME)
	echo "$(DISTNAME)" > fname
	for d in $(DISTSUBDIRS); do \
		mkdir -p $(DISTNAME)/$$d; \
		$(MAKE) -C $$d dist; \
	done
	ln $(DISTFILES) $(DISTNAME)/
	tar cfz $(DISTNAME).tar.gz $(DISTNAME)/
