include ../../Makeconf

ifdef USE_TERM
	TERM_DEF=-DUSE_TERM
endif

ifdef HAVE_LIB_TERMCAP
	TERM_LIB=-ltermcap
endif


all:	waitbar.oct

waitbar.oct:	waitbar.cc
	$(MKOCTFILE) $(TERM_DEF) waitbar.cc $(TERM_LIB)

