include ../Makeconf

# Needed for soct.oct
SORTDEFINES=$(HAVE_IEEE754_COMPLIANCE) $(HAVE_ND_ARRAYS)

RAND_LINKS = randn.oct rande.oct
PROGS = sort.oct rand.oct $(RAND_LINKS) 
#fsolve.oct

all: $(PROGS)

$(PROGS): Makefile

$(RAND_LINKS):
	-$(RM) $@
	$(LN_S) rand.oct $@

rand.oct : rand.cc ziggurat.h MersenneTwister.h
	$(MKOCTFILE) $(HAVE_ND_ARRAYS) $<

sort.oct : sort.cc oct-sort.cc oct-sort.h
	$(MKOCTFILE) $(SORTDEFINES) $<

# FIXES needs an install target because it isn't under main/ or extra/
install:
	@if test -f FIXES/NOINSTALL ; then \
	    echo skipping FIXES ; \
	else \
	    echo installing FIXES to $(MPATH)/FIXES ; \
	    ../$(INSTALLOCT) . $(MPATH)/FIXES $(OPATH) $(XPATH) ; \
	fi

clean: 
	-$(RM) *.o core octave-core core *.oct *~

