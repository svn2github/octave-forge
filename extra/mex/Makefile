sinclude ../../Makeconf

ifndef OCTAVE_FORGE
	MKOCTFILE = mkoctfile
	OPATH = $(shell pwd)
	bindir = /usr/local/bin
	mandir = /usr/local/man
	INSTALL = /usr/bin/install -c
	INSTALL_PROGRAM = $(INSTALL)
	INSTALL_DATA = $(INSTALL) -m 644
	LEAVEHERE=1
endif

man1dir = $(mandir)/man1

.PHONY: install

LIBPATH=$(OPATH)
MEXLIB=mex.o

all: $(MEXLIB) mex

$(MEXLIB): mex.cc mex.h matrix.h
	$(MKOCTFILE) -c $(HAVE_OCTAVE_MAP_INDEX) -o $(MEXLIB) mex.cc

mex: mex.in
	cat mex.in | sed -e "s:@MKOCTFILE@:$(MKOCTFILE):;s:@LIBPATH@:$(LIBPATH):g;s:@MEXLIB@:$(MEXLIB):g" > mex
	chmod a+x mex

install:
ifdef LEAVEHERE
	@echo "Leaving $(MEXLIB), mex.h and matrix.h in place --- do not remove!"
else
	 if ! test -e $(LIBPATH) ; then \
	  echo creating $(LIBPATH) ; \
	  $(INSTALL) -d $(LIBPATH) ; \
	fi
	 if test -d $(LIBPATH) ; then \
	  echo installing $(MEXLIB) mex/mex.h mex/matrix.h in $(LIBPATH) ; \
	  $(INSTALL_DATA) $(MEXLIB) $(LIBPATH)/$(MEXLIB) ; \
	  $(INSTALL_DATA) mex.h $(LIBPATH)/mex.h ; \
	  $(INSTALL_DATA) matrix.h $(LIBPATH)/matrix.h ; \
	fi
endif
	@if ! test -e $(man1dir) ; then \
	  echo creating $(man1dir) ; \
	  $(INSTALL) -d $(man1dir) ; \
	fi
	@if test -d $(man1dir) ; then \
	  echo installing mex/mex.1 in $(man1dir) ; \
	  $(RM) $(man1dir)/mex.1; \
	  $(INSTALL_DATA) mex.1 $(man1dir)/mex.1 ; \
	fi
	@if ! test -e $(bindir) ; then \
	  echo creating $(bindir) ; \
	  $(INSTALL) -d $(bindir) ; \
	fi
	@if test -d $(bindir) ; then \
	  echo installing mex/mex in $(bindir) ; \
	  $(RM) $(bindir)/mex ; \
	  $(INSTALL_SCRIPT) mex $(bindir)/mex ; \
	fi

clean: ; $(RM) mex mex_* $(MEXLIB) *.o *.oct core octave-core *~
