sinclude ../../Makeconf

PKG_FILES = COPYING DESCRIPTION INDEX $(wildcard inst/*) $(wildcard inst/control/*) $(wildcard inst/ocst/*)
SUBDIRS = doc/ control/ ocst/

.PHONY: $(SUBDIRS)

pre-pkg::
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir all; \
	done

clean:
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir $(MAKECMDGOALS); \
	done
