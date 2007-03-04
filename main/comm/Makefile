sinclude ../../Makeconf


PKG_FILES = COPYING DESCRIPTION INDEX PKG_ADD $(wildcard src/*) \
	$(wildcard inst/*) doc/comms.pdf
SUBDIRS = doc/

.PHONY: $(SUBDIRS)

pre-pkg::
	for _dir in $(SUBDIRS); do \
	  make -C $$_dir all; \
	done

clean:
	for _dir in $(SUBDIRS); do \
	  make -C $$_dir $(MAKECMDGOALS); \
	done
