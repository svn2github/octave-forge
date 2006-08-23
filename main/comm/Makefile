sinclude ../../Makeconf
sinclude ../../pkg.mk

PKG_FILES = $(patsubst %, comm/%, COPYING DESCRIPTION INDEX PKG_ADD \
	$(wildcard src/*) $(wildcard inst/*) doc/comms.pdf)
SUBDIRS = doc/

.PHONY: $(SUBDIRS)

pre-pkg/%::
	for _dir in $(SUBDIRS); do \
	  make -C $$_dir; \
	done

clean: $(SUBDIRS)
