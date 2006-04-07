sinclude ../Makeconf

# RANDFLAGS controls whether all 53 bits of mantissa are used. For 32 bits
# (~50% faster) use the following:
# 	make RANDFLAGS=
# for 53 bits use:
#	make RANDFLAGS=-DALLBITS
# The default is 53 bits.
# There are special optimizations for X86 architecture.  These are turned
# on automatically for -Di386, which is the default for gcc and icc on x86
# architectures, or for -DHAVE_X86_32.  You can override this by adding 
# -DUSE_X86_32=1 to enable or -DUSE_X86_32=0 to suppress onto the RANDFLAGS. 
# Enabling it will give incorrect results for BIG_ENDIAN architectures!  
# Also, it is important to choose the correct optimization level and CPU 
# type for X86 to get maximum performance.  The following works well for me:
#	CFLAGS="-O2 -march=i686" make
# Note that -O3 is much slower than -O2 for me.
RANDFLAGS = -DALLBITS

RAND_LINKS = $(patsubst %,%$(OCTLINK),randn rande randp randg)
PROGS = rand.oct $(RAND_LINKS) 
#fsolve.oct

all: $(PROGS)

#$(PROGS): Makefile

randtest: randmtzig.c
	$(CC) $(CFLAGS) $(RANDFLAGS) -DTEST randmtzig.c -o randtest -lm

$(RAND_LINKS):
	-$(RM) $@
	$(MKOCTLINK) rand.oct $@

rand.oct : randmtzig.c randpoisson.c randgamma.c rand.cc
	$(MKOCTFILE) $(RANDFLAGS) $(HAVE_ND_ARRAYS) rand.cc

# FIXES needs an install target because it isn't under main/ or extra/
install:
	@if test -f FIXES/NOINSTALL ; then \
	    echo skipping FIXES ; \
	else \
	    echo installing FIXES to $(DESTDIR)$(MPATH)/FIXES ; \
	    ../$(INSTALLOCT) . $(DESTDIR)$(MPATH)/FIXES \
	    $(DESTDIR)$(OPATH) $(DESTDIR)$(XPATH) ; \
	fi

clean: 
	-$(RM) *.o core octave-core core *.oct *~ randtest

# Do nothing for dist target
dist:
