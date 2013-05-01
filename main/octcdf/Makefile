PKG_FILES = COPYING DESCRIPTION INDEX PKG_ADD $(wildcard src/*) \
            $(wildcard inst/*) 
SUBDIRS = src/

.PHONY: $(SUBDIRS)

pre-pkg::
	$(MAKE) -C src clean

clean:
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir $(MAKECMDGOALS); \
	done
