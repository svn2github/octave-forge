include ../../Makeconf

PROGS=SymBand.oct SBSolve.oct

all: $(PROGS)

SBSolve.oct	:SymBand.oct
	ln -sf SymBand.oct SBSolve.oct 
	ln -sf SymBand.oct SBFactor.oct 
	ln -sf SymBand.oct SBBacksub.oct
	ln -sf SymBand.oct SBProd.oct 
	ln -sf SymBand.oct SBEig.oct 

clean	:
	rm -f *.o octave-core

cleanall	:
	rm -f *.o octave-core *.oct *~
