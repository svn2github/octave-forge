sinclude ../../Makeconf


PKG_FILES = COPYING DESCRIPTION INDEX $(wildcard src/*) \
	$(wildcard inst/*) $(wilcard bin/*) doc/*.pdf
SUBDIRS = doc/

.PHONY: $(SUBDIRS)

pre-pkg::
	@for _dir in $(SUBDIRS); do \
	  make -C $$_dir all; \
	done

clean:
	@for _dir in $(SUBDIRS); do \
	  make -C $$_dir $(MAKECMDGOALS); \
	done
