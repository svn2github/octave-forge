ifndef MKOCTFILE
MKOCTFILE := mkoctfile
endif

OCTS = fields2cell.oct fieldempty.oct structcat.oct cell2fields.oct

all: $(OCTS)

%.oct: %.cc
	$(MKOCTFILE) -s $<

clean: ; rm *.o *.oct
