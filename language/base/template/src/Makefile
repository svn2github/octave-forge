# Change the name "help" below to the name of the help function
HELP = help

all: $(HELP).oct

%.oct: %.cc
	mkoctfile $<

$(HELP).oct: Makefile md5.c md5.h $(HELP).cc
	mkoctfile $(HELP).cc md5.c

clean: ; -$(RM) *.o core octave-core *.oct *~
