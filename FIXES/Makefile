include ../Makeconf

PROGS = rand.oct randn.oct fsolve.oct

all: $(PROGS)

randn.oct: rand.oct
	-$(RM) randn.oct
	$(LN_S) rand.oct randn.oct

clean: 
	$(RM) *.o $(PROGS) octave-core core *~OA
