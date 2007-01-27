sinclude ../../Makeconf


PKG_FILES = COPYING DESCRIPTION INDEX PKG_ADD $(wildcard src/*) \
	$(wildcard inst/*) doc/*.pdf
SUBDIRS = doc/

.PHONY: $(SUBDIRS)

pre-pkg/%::
	@for _dir in $(SUBDIRS); do \
	  make -C $$_dir; \
	done

clean:
	@for _dir in $(SUBDIRS); do \
	  make -C $$_dir $(MAKECMDGOALS); \
	done
