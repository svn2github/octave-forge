sinclude ../../Makeconf

PKG_FILES = COPYING DESCRIPTION INDEX PKG_ADD $(wildcard src/int/*) \
	$(filter-out src/int, $(wildcard src/*)) \
	$(wildcard inst/*) $(wildcard examples/*) doc/fixed.pdf
SUBDIRS = doc/

.PHONY: $(SUBDIRS)

pre-pkg::
	@for _dir in $(SUBDIRS); do \
	  make -C $$_dir; \
	done

clean:
	@for _dir in $(SUBDIRS); do \
	  make -C $$_dir $(MAKECMDGOALS); \
	done
