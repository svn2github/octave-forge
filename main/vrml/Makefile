sinclude ../../Makeconf


PKG_FILES = COPYING DESCRIPTION INDEX $(wildcard src/*) \
	$(wildcard inst/*) $(wilcard data/*) doc/*.pdf doc/*.tex \
	doc/*.lyx doc/Makefile $(wildcard doc/figures/*)
SUBDIRS = doc/

.PHONY: $(SUBDIRS)

pre-pkg::
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir all; \
	done

clean:
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir clean ; \
	done
	find . \( -name \*~ -o -name \*.bak -o -name \#\* -o -name \.\#\* -\) -exec rm -f {} \;

documentation:
	make -C ./doc all

