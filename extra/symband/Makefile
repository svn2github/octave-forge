sinclude ../../Makeconf

SYMBAND_LINKS = SBSolve.oct SBFactor.oct SBBacksub.oct SBProd.oct SBEig.oct
PROGS = SymBand.oct $(SYMBAND_LINKS)

all: $(PROGS)

$(PROGS): Makefile

$(SYMBAND_LINKS):
	-$(RM) $@
	$(LN_S) SymBand.oct $@

clean: ; -$(RM) *.o core octave-core *.oct *~
