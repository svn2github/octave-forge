include ../../Makeconf

SF_BUILDSCRIPT=buildgsl_sf.sh
SF_LINKS=$(shell grep octave_name $(SF_BUILDSCRIPT) | sed 's/^.*octave_name=\([[:alnum:]_]*\) *$$/\1.oct/g')
RM=rm
LN_S=ln -s
#LIBS=$(shell gsl-config --libs-without-cblas)
LIBS=-lgsl

# all compiled functions
PROGS=legendre_sphPlm_array.oct gsl_sf.oct $(SF_LINKS)

all: gsl_sf.cc $(PROGS)

$(PROGS): Makefile

gsl_sf.cc: $(SF_BUILDSCRIPT)
	/bin/sh $(SF_BUILDSCRIPT)

gsl_sf.oct: gsl_sf.cc
	$(MKOCTFILE) $(LIBS) gsl_sf.cc

$(SF_LINKS): gsl_sf.oct
	-$(RM) -f $@
	$(LN_S) gsl_sf.oct $@

clean: ; -$(RM) gsl_sf.cc *.o core octave-core *.oct *~
