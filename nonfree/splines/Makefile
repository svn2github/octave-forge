sinclude ../../Makeconf

all: gcvspl.oct

gcvspl.oct: gcvspl.cc gcvsplf.f
	$(MKOCTFILE) -v gcvspl.cc gcvsplf.f

clean: ; -$(RM) *.o octave-core core *.oct *~

