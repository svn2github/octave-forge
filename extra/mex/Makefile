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
	cat mex.in | sed -e "s:@MKOCTFILE@:$(MKOCTFILE):;s:@LIBPATH@:$(LIBPATH):g;s:@MEXLIB@:$(MEXLIB):g" \
		-e 's;@AWK@;${AWK};g' > mex
	chmod a+x mex

install:
ifdef LEAVEHERE
	@echo "Leaving $(MEXLIB), mex.h and matrix.h in place --- do not remove!"
else
	@if ! test -e $(DESTDIR)$(LIBPATH) ; then \
	  echo creating $(DESTDIR)$(LIBPATH) ; \
	  $(INSTALL) -d $(DESTDIR)$(LIBPATH) ; \
	fi
	@if test -d $(DESTDIR)$(LIBPATH) ; then \
	  echo installing $(MEXLIB) mex/mex.h mex/matrix.h in $(DESTDIR)$(LIBPATH) ; \
	  $(INSTALL_DATA) $(MEXLIB) $(DESTDIR)$(LIBPATH)/$(MEXLIB) ; \
	  $(INSTALL_DATA) mex.h $(DESTDIR)$(LIBPATH)/mex.h ; \
	  $(INSTALL_DATA) matrix.h $(DESTDIR)$(LIBPATH)/matrix.h ; \
	fi
endif
	@if ! test -e $(DESTDIR)$(man1dir) ; then \
	  echo creating $(DESTDIR)$(man1dir) ; \
	  $(INSTALL) -d $(DESTDIR)$(man1dir) ; \
	fi
	@if test -d $(DESTDIR)$(man1dir) ; then \
	  echo installing mex/mex.1 in $(DESTDIR)$(man1dir) ; \
	  $(RM) $(DESTDIR)$(man1dir)/mex.1; \
	  $(INSTALL_DATA) mex.1 $(DESTDIR)$(man1dir)/mex.1 ; \
	fi
	@if ! test -e $(DESTDIR)$(bindir) ; then \
	  echo creating $(DESTDIR)$(bindir) ; \
	  $(INSTALL) -d $(DESTDIR)$(bindir) ; \
	fi
	@if test -d $(DESTDIR)$(bindir) ; then \
	  echo installing mex/mex in $(DESTDIR)$(bindir) ; \
	  $(RM) $(DESTDIR)$(bindir)/mex ; \
	  $(INSTALL_SCRIPT) mex $(DESTDIR)$(bindir)/mex ; \
	fi

clean: ; $(RM) mex mex_* $(MEXLIB) *.o *.oct core octave-core *~
