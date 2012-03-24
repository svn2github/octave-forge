all: cell2cell.oct partarray.oct sample.oct text_waitbar.oct 

MKOCTFILE = mkoctfile -Wall

%.oct: %.cc
	$(MKOCTFILE) $<

clean:
	rm -f *.o octave-core core *.oct *~
