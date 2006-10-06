sinclude ../../Makeconf
sinclude ../../pkg.mk

PKG_FILES = COPYING DESCRIPTION INDEX PKG_ADD $(wildcard src/*)
SUBDIRS = src/

.PHONY: $(SUBDIRS)

pre-pkg/%::
	make -C src clean

post-pkg/%::
	make -C src gsl_sf.cc

clean:
	@for _dir in $(SUBDIRS); do \
	  make -C $$_dir $(MAKECMDGOALS); \
	done
