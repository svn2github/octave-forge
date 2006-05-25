sinclude ../../Makeconf

PCHIP_OBJ = pchip_deriv.o dpchim.o dpchst.o

all: pchip_deriv.oct

pchip_deriv.oct: $(PCHIP_OBJ)
	$(MKOCTFILE) -v -o $@ $(PCHIP_OBJ)

clean: ; -$(RM) *.o octave-core core *.oct *~
