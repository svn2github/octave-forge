sinclude ../../Makeconf
ifndef MKOCTFILE
MKOCTFILE = mkoctfile
opath = $(shell pwd)
bindir = /usr/local/bin
mandir = /usr/local/man
INSTALL = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644
LEAVEHERE=1
endif

man1dir = $(mandir)/man1

all: mex.o mex

mex.o: mex.cc mex.h matrix.h
	$(MKOCTFILE) -v mex.cc
	$(RM) mex.oct

mex: mex.in
	cat mex.in | sed -e "s:@MKOCTFILE@:$(MKOCTFILE):" -e "s:@OPATH@:$(OPATH):g" > mex
	chmod a+x mex

install:
ifdef LEAVEHERE
	@echo "Leaving mex.o, mex.h and matrix.h in place --- do not remove!"
else
	@if ! test -e $(OPATH) ; then \
	  $(INSTALL) -d $(OPATH) ; \
	fi
	@if test -d $(OPATH) ; then \
	  $(INSTALL_DATA) mex.o $(OPATH)/mex.o ; \
	  $(INSTALL_DATA) mex.h $(OPATH)/mex.h ; \
	  $(INSTALL_DATA) matrix.h $(OPATH)/matrix.h ; \
	fi
endif
	@if ! test -e $(man1dir) ; then \
	  $(INSTALL) -d $(man1dir) ; \
	fi
	@if test -d $(man1dir) ; then \
	  $(RM) $(man1dir)/mex.1; \
	  echo "installing mex.1 in $(man1dir)" ; \
	  $(INSTALL_DATA) mex.1 $(man1dir)/mex.1 ; \
	fi
	@if ! test -e $(bindir) ; then \
	  $(INSTALL) -d $(bindir) ; \
	fi
	@if test -d $(bindir) ; then \
	  $(RM) $(bindir)/mex ; \
	  $(INSTALL_PROGRAM) mex $(bindir)/mex ; \
	fi

clean:
	$(RM) mex mex_* *.o *.oct core octave-core *~
