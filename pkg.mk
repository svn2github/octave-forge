# These are stub rules for the construction of packages

opkg = $(filter-out %/,$(subst /,/ ,$@))
ifeq ($(PKG_FILE),)
# Use the wildcard on INDEX and PKG_ADD as well to allow for their absence
PKG_FILES = COPYING DESCRIPTION $(wildcard INDEX) $(wildcard PKG_ADD) \
	$(wildcard PKG_DEL) $(wildcard post_install.m) \
	$(wildcard pre_install.m)  $(wildcard on_uninstall.m) \
	$(wildcard inst/*) $(wildcard src/*) \
	$(wildcard doc/*) $(wildcard bin/*)
endif
REAL_PKG_FILES = $(filter-out %/CVS %/.cvsignore %~ %/autom4te.cache, $(PKG_FILES))

pkg/%: pre-pkg/% real-pkg/% post-pkg/%
	@true

real-pkg/%:
	@ver=`grep "Version:" DESCRIPTION | sed -e "s/Version: *//" | \
	  sed -e "s/^\s*//" | sed -e "s/\s*$$//"`; \
	name=`grep "Name:" DESCRIPTION | sed -e "s/^Name: *//" | \
	  sed -e "s/^\s*//" | sed -e "s/\s*$$//" | \
	  sed -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`; \
	mkdir ../$(PKGDIR)/$$name-$$ver; \
	tar -cf - $(REAL_PKG_FILES) | (cd ../$(PKGDIR)/$$name-$$ver; tar -xf -); \
	cd ../$(PKGDIR); \
	tar -zcf $$name-$$ver.tar.gz $$name-$$ver; \
	rm -fr $$name-$$ver;

pre-pkg/%::
	@if [ -f src/autogen.sh ]; then \
          cd src; \
          sh ./autogen.sh; \
          cd ..; \
	fi

# By default do nothing post packaging
post-pkg/%::
	@true

