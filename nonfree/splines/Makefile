include ../../Makeconf

PROGS = gcvspl.oct

all: $(PROGS)

gcvspl.oct: gcvspl.cc gcvsplf.f
	$(MKOCTFILE) -v gcvspl.cc gcvsplf.f

clean: 
	-$(RM) *.o $(PROGS) octave-core core *~
   
