sinclude ../../Makeconf

SF_BUILDSCRIPT=buildgsl_sf.sh
SF_LINKS=$(shell grep octave_name $(SF_BUILDSCRIPT) | sed 's/^.*octave_name=\([[:alnum:]_]*\) *$$/\1.oct/g')
RM=rm
LN_S=ln -s
#LIBGSL=$(shell gsl-config --libs-without-cblas)
LIBGSL=-lgsl

# all compiled functions
PROGS=coupling_3j.oct coupling_6j.oct coupling_9j.oct legendre_sphPlm_array.oct gsl_sf.oct

%.oct: %.cc ; $(MKOCTFILE) $< $(LIBGSL)

ifdef HAVE_LIBGSL
all: gsl_sf.cc $(PROGS) $(SF_LINKS)
else
all:
endif

$(PROGS): Makefile

gsl_sf.cc: $(SF_BUILDSCRIPT)
	/bin/sh $(SF_BUILDSCRIPT)

$(SF_LINKS):
	-$(RM) -f $@
	$(LN_S) gsl_sf.oct $@

clean: ; -$(RM) gsl_sf.cc *.o core octave-core *.oct *~
