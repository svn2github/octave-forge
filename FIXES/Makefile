sinclude ../Makeconf

RAND_LINKS = randn.oct
PROGS = rand.oct fsolve.oct qr.oct sqrtm.oct $(RAND_LINKS)
QRSRC = qr.cc CmplxQR.cc  CmplxQRP.cc  dbleQR.cc  dbleQRP.cc
QROBJ = $(QRSRC:.cc=.o)

%.o : %.cc ; $(MKOCTFILE) -DHAVE_CONFIG_H -c -o $@ $<

all: $(PROGS)

$(PROGS): Makefile

qr.oct: $(QROBJ)
	$(MKOCTFILE) -o $@ $(QROBJ)

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
	-$(RM) *.o core octave-core core

distclean: clean
	-$(RM) *.oct *~
