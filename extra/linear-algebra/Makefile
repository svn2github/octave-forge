sinclude ../../Makeconf
ifndef MKOCTFILE
MKOCTFILE=mkoctfile
endif

all: chol.oct

chol.oct: chol.cc ov-re-tri.cc
	$(MKOCTFILE) -v chol.cc ov-re-tri.cc -o chol.oct

clean:
	$(RM) *.oct *.o *~ octave-core core
