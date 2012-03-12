all: csvexplode.oct csv2cell.oct csvconcat.oct cell2csv.oct

%.oct: %.cc
	mkoctfile -Wall $<

clean:
	rm -f *.o octave-core core *.oct *~
