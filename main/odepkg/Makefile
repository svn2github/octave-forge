# Filename:    Makefile
# Describtion: Makefile for the OdePkg directory
# ChangeLog: 20070227, this Makefile was originally be created
#    from the Makefile of the comm package. Modifications have
#    been done to create the OdePkg.

sinclude ../../Makeconf

PKG_FILES = COPYING DESCRIPTION INDEX $(wildcard src/*) $(wildcard inst/*) \
	doc/odepkg.pdf
SUBDIRS = doc/

.PHONY : $(SUBDIRS)

pre-pkg::
	@for _dir in $(SUBDIRS); do \
	  make -C $$_dir all; \
	done

clean :
	@for _dir in $(SUBDIRS); do \
	  make -C $$_dir $(MAKECMDGOALS); \
	done
	$(RM) *~ octave-core

realclean : clean

distclean : clean
