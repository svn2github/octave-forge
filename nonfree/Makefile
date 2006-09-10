sinclude ../Makeconf
sinclude ../pkg.mk

ifeq ($(PKGDIR),)
PKGDIR = ../packages/nonfree
else
PKGDIR += /nonfree
endif

# Determine which subdirectories are to be installed.  Of those, determine
# which have their own Makefile.
SUBMAKEDIRS = $(dir $(wildcard */Makefile))
NOINSTALLDIRS = $(dir $(wildcard */NOINSTALL))
BUILDDIRS = $(filter-out $(NOINSTALLDIRS), $(SUBMAKEDIRS))
INSTALLDIRS = $(filter-out $BUILDDIRS, $(filter-out CVS/ $(NOINSTALLDIRS), $(dir $(wildcard */.))))

.PHONY: all package clean distclean $(SUBMAKEDIRS)

ifdef OCTAVE_FORGE
all:

package: checkpkgdir $(patsubst %,dopkg/%,$(BUILDDIRS)) $(patsubst %,dopkg2/%,$(INSTALLDIRS))

checkpkgdir:
	@if [ ! -d $(PKGDIR) ]; then mkdir $(PKGDIR); fi

dopkg/%:
	$(MAKE) PKGDIR=$(PKGDIR) -C $(opkg) pkg/$(opkg)

dopkg2/%:
	@if [ -f $(opkg)/src/autogen.sh ]; then \
	  p=`pwd`; \
          cd $(opkg)/src; \
          sh ./autogen.sh; \
          cd $$p; \
	fi
	@ver=`grep "Version:" $(opkg)/DESCRIPTION | sed -e "s/Version: *//"`; \
	name=`grep Name: $(opkg)/DESCRIPTION | sed -e 's/^Name: *//' | \
	  sed -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`; \
	tar -zcf $(PKGDIR)/$$name-$$ver.tar.gz $(REAL_PKG_FILES)
else
package:
	@echo not yet configured

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
