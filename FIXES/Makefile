include ../Makeconf

RAND_LINKS = randn.oct
PROGS = rand.oct logm.oct sqrtm.oct $(RAND_LINKS) 
#fsolve.oct
 
all: $(PROGS)

$(PROGS): Makefile

$(RAND_LINKS):
	-$(RM) $@
	$(LN_S) rand.oct $@

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
