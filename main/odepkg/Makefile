# Filename:    Makefile
# Description: Makefile for OdePkg
# ChangeLog: 20070222, this Makefile was originally be created
#    from the Makefile of the comm package. Modifications have
#    been done to create OdePkg.

sinclude ../../Makeconf

PKG_FILES = COPYING DESCRIPTION INDEX $(wildcard src/*) $(wildcard inst/*) \
	doc/odepkg.pdf doc/Makefile $(wildcard doc/*.texi)
SUBDIRS = doc/

.PHONY : $(SUBDIRS)

pre-pkg::
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir all; \
	done

clean :
	@for _dir in $(SUBDIRS); do \
	  $(MAKE) -C $$_dir $(MAKECMDGOALS); \
	done
	$(RM) *~ octave-core

realclean : clean

distclean : clean
