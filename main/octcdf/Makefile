sinclude ../../Makeconf


PKG_FILES = COPYING DESCRIPTION INDEX PKG_ADD $(wildcard src/*) \
            $(wildcard inst/*) 
SUBDIRS = src/

.PHONY: $(SUBDIRS)

pre-pkg::
	make -C src clean

clean:
	@for _dir in $(SUBDIRS); do \
	  make -C $$_dir $(MAKECMDGOALS); \
	done
