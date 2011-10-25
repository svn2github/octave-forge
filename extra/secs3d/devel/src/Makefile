# http://MatrixProgramming.com/
# http://Evgenii.Rudnyi.Ru/

# Please define where to find include files and libraries for MUMPS
# The METIS library should be also there
#
# In case of MS VC it is also possible to use environment variable 
# INCLUDE and LIB. In a case leave these two variables blank 
INCLOC = /opt/MUMPS/4.10.0/include
LIBLOC = /opt/MUMPS/4.10.0/lib

#define C++ compiler and its flags
MKOCTFILE     = mkoctfile

# define BLAS libraries (right now it is VecLib)
LIBBLAS     = -framework Accelerate
LIBGFORTRAN = /usr/lib/gcc/i686-apple-darwin10/4.2.1/
LIBMUMPS    = -L$(LIBLOC) -ldmumps -lmumps_common -lpord -L/opt/MUMPS/4.10.0/libseq -lmpiseq

all: mumps_test

mumps_solve : mumps_solve.o 
	$(MKOCTFILE) -o $@ $@.o $(LIBMUMPS) 

%.o: %.cc 
	$(MKOCTFILE) -I. -I$(INCLOC) -c $*.cpp

clean:
	$(RM)  *.o 

distclean: clean
	$(RM) mumps_solve

