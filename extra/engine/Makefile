# Makefile for MATLAB compatible liboct library           Sept. 8, 1998
#
# Copyright (C) 1998 by Jesse Bennett.
#
# 2000-11-23: Paul Kienzle (pkienzle@kienzle.powernet.co.uk)
#   - added -D_BSD_SOURCE to the compile options so mknod could be found
# 2001-09-19 Paul Kienzle
#   - use default $(CC), $(AR) and $(RANLIB)
#   - remove unused flags

# CONFIGURE: compiler flags go here.
# CFLAGS =	-Wall -ansi -pedantic -O2 -D_BSD_SOURCE -DDEBUGAPI
CFLAGS =	-Wall -ansi -pedantic -O2 -D_BSD_SOURCE

# CONFIGURE: sources, includes, objects and libraries used.
INCS =		engine.h engif.h
TARGETS =	engif.o engClose.o engEvalString.o engGetFull.o \
		engOpen.o engPutFull.o engOutputBuffer.o mxCalloc.o mxFree.o

all:		liboct.a mattest

liboct.a:	$(TARGETS)
	$(AR) -r liboct.a $?
	$(RANLIB) liboct.a
	$(AR) -tv liboct.a

mattest:	liboct.a
	$(CC) $(CFLAGS) mattest.c -o mattest -loct -lm

clean:
	$(RM) $(TARGETS) liboct.a mattest

%.o : %.c
	$(CC) $(CFLAGS) -c $*.c

