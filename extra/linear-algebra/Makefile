sinclude ../../Makeconf

OBJ = chol.o ov-re-tri.o

all: chol.oct

chol.oct: $(OBJ)
	$(MKOCTFILE) -o $@ $(OBJ)

ov-re-tri.o: ov-re-tri.cc ov-re-tri.h
	$(MKOCTFILE) $(TYPEID_HAS_CLASS) -c $< -o $@

chol.o: ov-re-tri.h

clean: ; $(RM) *.o core octave-core *.oct *~
