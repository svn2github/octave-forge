include ../../Makeconf

OBJ = chol.o ov-re-tri.o

all: chol.oct

chol.oct: $(OBJ)
	$(MKOCTFILE) -o $@ $(OBJ)

clean: ; $(RM) *.o core octave-core *.oct *~
