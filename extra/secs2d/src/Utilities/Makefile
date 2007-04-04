
ccfiles  := $(wildcard *.cc)
octfiles := $(patsubst %.cc, %.oct, $(ccfiles) )
objfiles := $(patsubst %.cc, %.o,   $(ccfiles) )

all: $(octfiles)

$(objectfile): Makefile

%.o: %.cc
	mkoctfile -c $(patsubst %.o, %.cc, $@ ) -o $@

%.oct:  %.o $(filter-out $<, $(objfiles) ) 
	mkoctfile -s $< $(filter-out $<, $(objfiles) ) -o $@
	strip -x $@

clean: ; -$(RM) *.o core octave-core *.oct *~