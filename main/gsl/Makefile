sinclude ../../Makeconf


PKG_FILES = COPYING DESCRIPTION INDEX PKG_ADD $(wildcard src/*) \
	$(wildcard inst/*) $(wildcard doc/*) 
SUBDIRS = src/

.PHONY: $(SUBDIRS)

pre-pkg::
	$(MAKE) -C src clean

post-pkg::
	$(MAKE) -C src gsl_sf.cc

clean:
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir $(MAKECMDGOALS); \
	done
