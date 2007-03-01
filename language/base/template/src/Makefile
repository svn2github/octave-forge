# Change the name "help" below to the name of the help function
HELP = help

all: $(HELP).oct

%.oct: %.cc
	mkoctfile $<

$(HELP).oct: Makefile help.icc $(HELP).cc
	mkoctfile $(HELP).cc

clean: ; -$(RM) *.o core octave-core *.oct *~
