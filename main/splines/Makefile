sinclude ../../Makeconf

TRISOLVE_OBJ = trisolve.o dgtsv.o dptsv.o dpttrf.o dpttrs.o dptts2.o
PCHIP_OBJ = pchip_deriv.o dpchim.o dpchst.o

all: trisolve.oct pchip_deriv.oct

trisolve.oct: $(TRISOLVE_OBJ)
	$(MKOCTFILE) -v -o $@ $(TRISOLVE_OBJ)

pchip_deriv.oct: $(PCHIP_OBJ)
	$(MKOCTFILE) -v -o $@ $(PCHIP_OBJ)

clean: ; -$(RM) *.o octave-core core *.oct *~
