include ../../Makeconf

TRISOLVE_OBJ = trisolve.o dgtsv.o dptsv.o dpttrf.o dpttrs.o dptts2.o

all: trisolve.oct

trisolve.oct: $(TRISOLVE_OBJ)
	$(MKOCTFILE) -v -o $@ $(TRISOLVE_OBJ)

clean: ; -$(RM) *.o octave-core core *.oct *~
