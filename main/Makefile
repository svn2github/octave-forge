sinclude ../Makeconf
sinclude ../pkg.mk

ifeq ($(PKGDIR),)
PKGDIR = ../packages
endif

# Determine which subdirectories are to be installed.  Of those, determine
# which have their own Makefile.
SUBMAKEDIRS = $(dir $(wildcard */Makefile))
NOINSTALLDIRS = $(dir $(wildcard */NOINSTALL))
BUILDDIRS = $(filter-out $(NOINSTALLDIRS), $(SUBMAKEDIRS))
INSTALLDIRS = $(filter-out $BUILDDIRS, $(filter-out CVS/ $(NOINSTALLDIRS), $(dir $(wildcard */.))))

.PHONY: all install clean distclean $(SUBMAKEDIRS)

ifdef OCTAVE_FORGE
all: $(patsubst %,dopkg/%,$(BUILDDIRS)) $(patsubst %,dopkg2/%,$(INSTALLDIRS))

dopkg/%:
	$(MAKE) PKGDIR=$(PKGDIR) -C $(pkg) pkg/$(pkg)

dopkg2/%:
	ver=`grep "Version:" $(pkg)/DESCRIPTION | sed -e "s/Version: *//"`; \
	tar -zcf $(PKGDIR)/$(pkg)-$$ver.tar.gz $(REAL_PKG_FILES)

else
all:
	@echo not yet configured
endif

clean: $(SUBMAKEDIRS)

# Propogate make to the subdirectory if the goal is a valid target
# in the subdirectory Makefile.
$(SUBMAKEDIRS):
	@echo Processing main/$@...
	@if test -z "$(MAKECMDGOALS)" ; then \
	    cd $@ && $(MAKE) ; \
	elif grep "^$(MAKECMDGOALS) *[:]" $@Makefile >/dev/null ; then \
	    cd $@ && $(MAKE) $(MAKECMDGOALS) ; \
	fi

