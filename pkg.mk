# These are stub rules for the construction of packages

opkg = $(filter-out %/,$(subst /,/ ,$@))
ifeq ($(PKG_FILE),)
# Use the wildcard on INDEX and PKG_ADD as well to allow for their absence
PKG_FILES = $(opkg)/COPYING $(opkg)/DESCRIPTION \
	$(wildcard $(opkg)/INDEX) $(wildcard $(opkg)/PKG_ADD) \
	$(wildcard $(opkg)/inst/*) $(wildcard $(opkg)/src/*) \
	$(wildcard $(opkg)/doc/*)
endif
REAL_PKG_FILES = $(filter-out $(opkg)/%/CVS $(opkg)/%/.cvsignore %~ %/autom4te.cache, $(PKG_FILES))

pkg/%: pre-pkg/%
	cd ..; \
	ver=`grep "Version:" $(opkg)/DESCRIPTION | sed -e "s/Version: *//"`; \
	name=`grep Name: comm/DESCRIPTION | sed -e 's/^Name: *//' | \
	  sed -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`; \
	tar -zcf $(PKGDIR)/$$name-$$ver.tar.gz $(REAL_PKG_FILES); \
	cd $(opkg); \
	$(MAKE) post-pkg/$(opkg)

pre-pkg/%::
	if [ -f src/autogen.sh ]; then \
          cd src; \
          sh ./autogen.sh; \
          cd ..; \
	fi

# By default do nothing post packaging
post-pkg/%::
	@true

