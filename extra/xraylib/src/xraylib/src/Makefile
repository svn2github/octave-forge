PROGNAME = libxrl.a
NAME = xraylib
VERSION = 2.4
CC = gcc
CFLAGS += -fPIC
LDOPTS = 
LIBS = 
INCLUDES = 
LIBPATH = 
SHELL = /bin/bash

OBJ = xrayvars.o cross_sections.o \
scattering.o atomicweight.o edges.o fluor_lines.o fluor_yield.o jump.o \
coskron.o radrate.o cs_line.o polarized.o splint.o cs_barns.o

EXTERNAL_OBJ = xrayfiles.o xrayglob.o

INLINE_OBJ = xrayglob_inline.o xrayfiles_inline.o

#------------- commands ----------------

%.o : %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $<

all: inline

external: $(EXTERNAL_OBJ) $(OBJ)
	-rm $(PROGNAME)	
	ar cru $(PROGNAME) $(EXTERNAL_OBJ) $(OBJ)
	ranlib $(PROGNAME)
	touch external_stamp

xrayglob_inline.c: prdata
	XRAYLIB_DIR="../" ./prdata

inline: $(INLINE_OBJ) $(OBJ) xrayglob_inline.c
	-rm $(PROGNAME)
	ar cru $(PROGNAME) $(INLINE_OBJ) $(OBJ)
	ranlib $(PROGNAME)
	touch inline_stamp

external_stamp: external

prdata: external_stamp
	$(CC) $(CFLAGS) $(INCLUDES) pr_data.c libxrl.a -o prdata

clean:
	rm -f $(PROGNAME) *.lo *.o *~ core external_stamp inline_stamp prdata xrayglob_inline.c
