sinclude ../../Makeconf

ifndef OCTAVE_FORGE
	MKOCTFILE = mkoctfile -v
endif
	HAVE_RS = 0

SOURCES = gfprimdf.cc gftuple.cc rspoly.cc \
	rsdeco.cc rsdeco_ccsds.cc rsenco.cc rsenco_ccsds.cc
TARGETS = $(patsubst %.cc,%.oct,$(SOURCES))
OBJECTS = $(patsubst %.cc,%.o,$(SOURCES))
DEPENDS = $(patsubst %.cc,%.d,$(SOURCES))


.SUFFIXES:

#.PHONY: clean cleanobj cleandep purge

# --------------------------------------------------------------------
ifeq ($(HAVE_RS),1)
# If we already have a system shared object copy of the reed-solomon
# library librs, then we don't need to build our own.  Additionally,
# there is nothing to be gained by putting all the files together into
# one big file and symlinking to that, so do a simple build.  

# If we happen to pick up a static system version of the reed-solomon 
# library that's a bit of a problem.  Hopefully it's just an extra 40k 
# of binary, but if librs contains global or static variables, different 
# functions will have different copies and it may be a problem.

all: $(TARGETS)

INCLUDES =
LIBS = -lrs

# --------------------------------------------------------------------
else
# If we don't have the reed-solomon library, build our own local copy.
# We use the standard trick of putting all the DEFUNs in one big file
# and symlinking to that so that only one copy of the library is used.

all: __rs.oct $(TARGETS)

$(TARGETS): ; $(LN_S) __rs.oct $@

INCLUDES = -I./reed-solomon
LIBS = -L./reed-solomon -lrs

# We should be linking $(OBJECTS) together to produce __rs.oct, but we
# can't because for some reason liboctave/str-vec.h includes a static
# qsort comparison function?! so for now lets join them together into
# one big file.
__rs.oct: __rs.o reed-solomon/librs.a
	$(MKOCTFILE) -o __rs.oct __rs.o $(LIBS)

__rs.o: __rs.cc rsoct.h reed-solomon/*.h
	$(MKOCTFILE) -c __rs.o __rs.cc $(INCLUDES)

__rs.cc: $(SOURCES)
	-$(RM) __rs.cc
	cat $(SOURCES) > __rs.cc

reed-solomon/librs.a: $(wildcard reed-solomon/*.[ch]) reed-solomon/makefile
	cd reed-solomon && $(MAKE) librs.a

reed-solomon/makefile: reed-solomon/makefile.in
	-$(RM) reed-solomon/makefile
	sed -e "s/@CC@/$(CC)/g" -e "s/@CFLAGS@/$(CFLAGS)/g" -e "s/@ARCH[^@]*@//g" < reed-solomon/makefile.in > reed-solomon/makefile

endif
# --------------------------------------------------------------------

SUFFIXES:
SUFFIXES: .cc .oct .o .h

ifneq (,$(wildcard *.d))
include $(wildcard *.d)
endif

%.oct : %.cc ;

%.oct : %.o
	echo "Linking $@"; \
	$(MKOCTFILE) $< $(LIBS) -o $@

%.o:%.cc
	@echo "Compiling $@"; \
	$(MKOCTFILE) $(INCLUDES) -c $< 

install: all
	@echo "Installing..."; \
	install -C $(TARGETS) $(INSTALLDIR)

clean:
	@echo "Cleaning..."
	-cd reed-solomon && $(MAKE) clean
	-$(RM) *.d *.o *~ core octave-core *.oct __rs.cc reed-solomon/makefile

purge:
	@echo "Purging..."; \
	-$(RM) *.d *.o *.oct *~ core octave-core

count:
	wc *{.cc,.h}
