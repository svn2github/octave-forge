sinclude ../Makeconf

# Needed for sort.oct
SORTDEFINES=$(HAVE_IEEE754_COMPLIANCE) $(HAVE_ND_ARRAYS)

# This bit of logic decides whether to build sort.oct or not, as it
# is include in octave versions 2.1.58 and greater
t2.1.58=sort.oct
SORT_BUILD=$($(word 2, $(sort t$(OCTAVE_VERSION) t2.1.58)))

RAND_LINKS = randn.oct rande.oct
PROGS = $(SORT_BUILD) rand.oct $(RAND_LINKS) 
#fsolve.oct

all: $(PROGS)

$(PROGS): Makefile

$(RAND_LINKS):
	-$(RM) $@
	$(LN_S) rand.oct $@

rand.oct : randmtzig.c rand.cc MersenneTwister.h
	$(MKOCTFILE) $(HAVE_ND_ARRAYS) $(ALLBITS) rand.cc

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

# Do nothing for dist target
dist:
