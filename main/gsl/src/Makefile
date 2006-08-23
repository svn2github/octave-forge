sinclude Makeconf

SF_BUILDSCRIPT=buildgsl_sf.sh
RM=rm
#LIBGSL=$(shell gsl-config --libs-without-cblas)
LIBGSL=-lgsl

# all automatically generated functions
SF_ALL_FNS=$(shell grep octave_name $(SF_BUILDSCRIPT) | sed 's/^.*octave_name=\([[:alnum:]_]*\) *$$/\1/g')
SF_AVAILABLE=$(filter-out $(GSL_MISSING),$(SF_ALL_FNS))

# all separately compiled functions
PROGS=coupling_3j.oct coupling_6j.oct coupling_9j.oct legendre_sphPlm_array.oct gsl_sf.oct

%.oct: %.cc ; $(MKOCTFILE) $< $(LIBGSL)

ifeq ($(HAVE_GSL),yes)
all: gsl_sf.cc $(SF_LINKS) $(PROGS)
else
all:
	@echo "GSL libraries or headers not installed"
	false
endif

$(PROGS): Makefile

gsl_sf.cc: $(SF_BUILDSCRIPT)
	${SHELL} $(SF_BUILDSCRIPT) $(GSL_MISSING)

clean: ; -$(RM) gsl_sf.cc *.o core octave-core *.oct *~
