include ../../Makeconf

ifdef HAVE_TERM_H
	TERM_DEF=-DHAVE_TERM_H
endif


all:	waitbar.oct

waitbar.oct:	waitbar.cc
	$(MKOCTFILE) $(TERM_DEF) waitbar.cc

