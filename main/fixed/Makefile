sinclude ../../Makeconf
sinclude ../../pkg.mk

PKG_FILES = COPYING DESCRIPTION INDEX PKG_ADD $(wildcard src/*) \
	$(wildcard inst/*) $(wildcard examples/*) doc/fixed.pdf
SUBDIRS = doc/

.PHONY: $(SUBDIRS)

pre-pkg/%::
	for _dir in $(SUBDIRS); do \
	  make -C $$_dir; \
	done

clean: $(SUBDIRS)
