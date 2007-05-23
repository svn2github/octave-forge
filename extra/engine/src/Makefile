# Makefile for MATLAB compatible liboct library           Sept. 8, 1998
#
# Copyright (C) 1998 by Jesse Bennett.
#
# 2000-11-23: Paul Kienzle (pkienzle@kienzle.powernet.co.uk)
#   - added -D_BSD_SOURCE to the compile options so mknod could be found
# 2001-09-19 Paul Kienzle
#   - use default $(CC), $(AR) and $(RANLIB)
#   - remove unused flags
# 2002-03-17 Paul Kienzle
#   - use default $(ARFLAGS), $(CFLAGS)
#   - install header and library in the appropriate directories

# use octave-forge configuration info if it is available
sinclude ./Makeconf

ifndef OCTAVE_FORGE
	RANLIB ?= :
	libdir = /usr/local/lib
	includedir = /usr/local/include
	INSTALL = /usr/bin/install -c
	INSTALL_PROGRAM = $(INSTALL)
	INSTALL_DATA = $(INSTALL) -m 644
endif
AR ?= ar
ARFLAGS ?= rc

# CONFIGURE: sources, includes, objects and libraries used.
INCS =		engine.h engif.h
TARGETS =	engif.o engClose.o engEvalString.o engGetFull.o \
		engOpen.o engPutFull.o engOutputBuffer.o mxCalloc.o mxFree.o

all:		liboct.a mattest
	@if [ -f FILES ]; then \
	  $(RM) -f FILES; \
	fi; \
	touch FILES; \
	for _f in liboct.a engine.h; do \
	  echo $$_f >> FILES; \
	done

%.o : %.c ; $(CC) $(CFLAGS) -D_BSD_SOURCE -c $*.c

liboct.a:	$(TARGETS)
	$(AR) $(ARFLAGS) liboct.a $(TARGETS) > /dev/null 2>&1
	$(RANLIB) liboct.a

mattest:	mattest.o liboct.a
	$(CC) mattest.o -o mattest liboct.a -lm

clean: ; -$(RM) *.o liboct.a mattest
