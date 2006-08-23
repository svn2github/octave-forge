# These are stub rules for the construction of packages

pkg = $(filter-out %/,$(subst /,/ ,$@))
ifeq ($(PKG_FILE),)
# Use the wildcard on INDEX and PKG_ADD as well to allow for their absence
PKG_FILES = $(pkg)/COPYING $(pkg)/DESCRIPTION \
	$(wildcard $(pkg)/INDEX) $(wildcard $(pkg)/PKG_ADD) \
	$(wildcard $(pkg)/inst/*) $(wildcard $(pkg)/src/*)
endif
REAL_PKG_FILES = $(filter-out $(pkg)/%/CVS $(pkg)/%/.cvsignore %~, $(PKG_FILES))

pkg/%: pre-pkg/%
	cd ..; \
	ver=`grep "Version:" $(pkg)/DESCRIPTION | sed -e "s/Version: *//"`; \
	tar -zcf $(PKGDIR)/$(pkg)-$$ver.tar.gz $(REAL_PKG_FILES); \
	cd $(pkg); \
	$(MAKE) post-pkg/$(pkg)

pre-pkg/%::
	if [ -f src/autogen.sh ]; then \
          cd src; \
          sh ./autogen.sh; \
          cd ..; \
	fi

# By default do nothing post packaging. Therefore trailing TAB is important!!!
post-pkg/%::
	
