OCTS = arefields.oct fields2cell.oct fieldempty.oct structcat.oct \
       cell2fields.oct

all: $(OCTS)

%.oct: %.cc
	mkoctfile -s $<

clean: ; rm *.o *.oct
