sinclude ../../Makeconf

PKG_FILES = COPYING DESCRIPTION INDEX PKG_ADD $(wildcard src/int/*) \
	$(filter-out src/int, $(wildcard src/*)) \
	$(wildcard inst/*) $(wildcard examples/*) doc/fixed.pdf
SUBDIRS = doc/

.PHONY: $(SUBDIRS)

pre-pkg::
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir all; \
	done

clean:
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir $(MAKECMDGOALS); \
	done
