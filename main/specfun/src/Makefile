all: ellipj.oct

%.oct: %.cc
	mkoctfile -s $<

clean: ; -rm *.o core octave-core *.oct *~
