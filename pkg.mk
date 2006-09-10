# These are stub rules for the construction of packages

opkg = $(filter-out %/,$(subst /,/ ,$@))
ifeq ($(PKG_FILE),)
# Use the wildcard on INDEX and PKG_ADD as well to allow for their absence
PKG_FILES = COPYING DESCRIPTION $(wildcard INDEX) $(wildcard PKG_ADD) \
	$(wildcard PKG_DEL) $(wildcard post_install.m) \
	$(wildcard pre_install.m)  $(wildcard on_uninstall.m) \
	$(wildcard inst/*) $(wildcard src/*) $(wildcard doc/*) \
	$(wildcard bin/*)
endif
REAL_PKG_FILES = $(filter-out $(opkg)/%/CVS $(opkg)/%/.cvsignore %~ %/autom4te.cache, $(patsubst %, $(opkg)/%, $(PKG_FILES)))

pkg/%: pre-pkg/%
	@ver=`grep "Version:" DESCRIPTION | sed -e "s/Version: *//"`; \
	name=`grep Name: DESCRIPTION | sed -e 's/^Name: *//' | \
	  sed -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`; \
	cd ..; \
	tar -zcf $(PKGDIR)/$$name-$$ver.tar.gz $(REAL_PKG_FILES); \
	cd $(opkg); \
	$(MAKE) post-pkg/$(opkg)

pre-pkg/%::
	@if [ -f src/autogen.sh ]; then \
          cd src; \
          sh ./autogen.sh; \
          cd ..; \
	fi

# By default do nothing post packaging
post-pkg/%::
	@true

