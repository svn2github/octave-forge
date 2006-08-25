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
	$(MAKE) PKGDIR=$(PKGDIR) -C $(opkg) pkg/$(opkg)

dopkg2/%:
	if [ -f $(opkg)/src/autogen.sh ]; then \
	  p=`pwd`; \
          cd $(opkg)/src; \
          sh ./autogen.sh; \
          cd $$p; \
	fi
	ver=`grep "Version:" $(opkg)/DESCRIPTION | sed -e "s/Version: *//"`; \
	tar -zcf $(PKGDIR)/$(opkg)-$$ver.tar.gz $(REAL_PKG_FILES)
else
all:
	@echo not yet configured
endif

clean: $(SUBMAKEDIRS)

# Propogate make to the subdirectory if the goal is a valid target
# in the subdirectory Makefile.
$(SUBMAKEDIRS):
	@echo Processing extra/$@
	@if test -z "$(MAKECMDGOALS)" ; then \
	    cd $@ && $(MAKE) ; \
	elif grep "^$(MAKECMDGOALS) *[:]" $@Makefile >/dev/null; then \
	    cd $@ && $(MAKE) $(MAKECMDGOALS) ; \
	fi
