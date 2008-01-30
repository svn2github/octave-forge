all: dlmread.oct dlmreadnew.oct textread.oct

%.oct: %.cc
	mkoctfile $<

clean:
	-rm *.o core octave-core *.oct *~
