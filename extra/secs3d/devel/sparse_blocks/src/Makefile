CXX         = g++-4.2
CXXFLAGS    = -m32
INCLOC      = /opt/MUMPS/4.10.0/include 
MPIINC      = /opt/openmpi/1.4.3/include/
LIBLOC      = /opt/MUMPS/4.10.0/lib
LIBBLAS     = -framework Accelerate
LIBGFORTRAN = -L/usr/lib/gcc/i686-apple-darwin10/4.2.1/ -lgfortran -lgfortranbegin
LIBMUMPS    = -L$(LIBLOC) -ldmumps -lmumps_common -lpord -L/opt/openmpi/1.4.3/lib \
-lmpi -lmpi_f77 -lmpi_cxx -L/opt/scalapack/lib -lscalapack /opt/blacs/lib/blacs.a \
/opt/blacs/lib/blacsC.a
MPICXX      = /opt/openmpi/1.4.3/bin/mpic++

sparse_test: sparse_test.o sparse.o mumps_class.o
	$(MPICXX) $(CXXFLAGS) \
	$(LIBMUMPS) \
	$(LIBGFORTRAN) \
	$(LIBBLAS) \
	-I$(MPIINC) \
	sparse.o mumps_class.o sparse_test.o -o sparse_test

sparse_test.o: sparse_test.cc mumps_solve.h sparse.h
	$(MPICXX) $(CXXFLAGS) -I$(INCLOC) -I. -c sparse_test.cc

sparse.o: sparse.cc sparse.h
	$(MPICXX) $(CXXFLAGS) -I. -c sparse.cc

mumps_class.o: mumps_class.cc mumps_class.h sparse.h
	$(MPICXX) $(CXXFLAGS) -I. -I$(INCLOC) -c mumps_class.cc

mumps_solve.o: mumps_solve.cc mumps_solve.h mumps_class.h sparse.h
	$(MPICXX) $(CXXFLAGS) -I. -I$(INCLOC) -c mumps_solve.cc

clean:
	$(RM) sparse.o sparse_test.o mumps_solve.o mumps_class.o

distclean: clean
	$(RM) sparse_test

.PHONY: clean distclean
