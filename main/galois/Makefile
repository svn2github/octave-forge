sinclude ../../Makeconf


PKG_FILES = COPYING DESCRIPTION INDEX $(wildcard src/*) \
	$(wildcard inst/*) 
SUBDIRS = src

.PHONY: $(SUBDIRS)

pre-pkg::
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir pre-pkg; \
	done

clean:
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir $(MAKECMDGOALS); \
	done

build::
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir all; \
	done

check:: build
	@$(RM) __check__.m
	@find . -name "*.m" -exec grep %\! {} \; -o -name "*.cc" -exec grep %\! {} \; >> __check__.m
	@octave -q --eval 'addpath("./src"); addpath("./inst"); test("__check__","normal",stdout);'
	@$(RM) __check__.m
