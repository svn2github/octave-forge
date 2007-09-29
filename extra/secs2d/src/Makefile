
ccfiles  := $(wildcard *.cc)
octfiles := $(patsubst %.cc, %.oct, $(ccfiles) )
objfiles := $(patsubst %.cc, %.o,   $(ccfiles) )

all: $(octfiles)

$(objectfile): Makefile

%.o: %.cc
	mkoctfile -c $(patsubst %.o, %.cc, $@ ) -o $@

Uscharfettergummel.oct: Uscharfettergummel.o Ubern.o
	mkoctfile -s $< Ubern.o -o $@
	$(RM) Uscharfettergummel.o

%.oct:  %.o  
	mkoctfile -s $< -o $@
	#strip -x $@

clean:
	$(RM) *.o core octave-core *.oct *~
