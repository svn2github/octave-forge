include ../../Makeconf

PROGS = trisolve.oct

all: $(PROGS)

trisolve.oct:
	$(MKOCTFILE) -v trisolve.cc \
	dgtsv.f  dptsv.f  dpttrf.f  dpttrs.f  dptts2.f

clean: 
	$(RM) *.o $(PROGS) octave-core core *~
