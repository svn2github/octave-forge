
include ../Makeconf

SUBMAKES = $(wildcard */Makefile)
MAKE_SUBDIRS = $(dir $(SUBMAKES))
INSTALL_SUBDIRS = $(filter-out Makefile, $(wildcard *))

.PHONY: all install clean $(MAKE_SUBDIRS) $(INSTALL_SUBDIRS)

all: $(MAKE_SUBDIRS)

$(MAKE_SUBDIRS):
	@if test ! -f $@/NOINSTALL || test x$(MAKECMDGOALS) = xclean ; then \
	    cd $@ && $(MAKE) $(MAKECMDGOALS) ; \
	fi

install: $(INSTALL_SUBDIRS)
	@if test ! -f mex/NOINSTALL ; then \
	    cd mex && $(MAKE) install ; \
	fi

$(INSTALL_SUBDIRS):
	@if test -f $@/NOINSTALL ; then \
	    echo skipping $@ ; \
	else \
	    echo installing $@ to $(MPATH)/$@ ; \
	    ../$(INSTALLOCT) $@ $(MPATH)/$@ $(OPATH) $(XPATH) ; \
	fi

clean: $(MAKE_SUBDIRS)

