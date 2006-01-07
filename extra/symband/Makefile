sinclude ../../Makeconf

SYMBAND_LINKS = $(patsubst %,%$(OCTLINK), SBSolve SBFactor SBBacksub SBProd SBEig)
PROGS = SymBand.oct $(SYMBAND_LINKS)

all: $(PROGS)

$(PROGS): Makefile

$(SYMBAND_LINKS):
	-$(RM) $@
	$(MKOCTLINK) SymBand.oct $@

clean: ; -$(RM) *.o core octave-core *.oct *~
