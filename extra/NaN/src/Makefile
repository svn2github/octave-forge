
MATLABDIR = /usr/local/matlab
CC  	= gcc
CXX 	= g++
CFLAGS 	= -Wall -Wconversion -O3 -fPIC -I/usr/include/octave
OCTMEX	= mkoctfile --mex

#CFLAGS	= -Wall -Wconversion -O3 -fPIC -I$(MATLABDIR)/extern/include
# comment the following line if you use MATLAB on 32-bit computer
MEX_OPTION += -largeArrayDims
MATMEX	= $(MATLABDIR)/bin/mex $(MEX_OPTION)
MEX_EXT = $(shell $(MATLABDIR)/bin/mexext)

PROGS = $(patsubst %_mex.cpp,%_mex.mex,$(wildcard *.cpp))

matlab: $(patsubst %_mex.cpp,%_mex.$(MEX_EXT),$(wildcard *.cpp))
octave: $(patsubst %_mex.cpp,%_mex.mex,$(wildcard *.cpp))
all: matlab octave

$(PROGS): Makefile

%.oct: %.cc
	mkoctfile $<

%.mex: %.cpp
	$(OCTMEX) $<           ## Octave
%.$(MEX_EXT): %.cpp
	$(MATMEX) $<           ## Matlab


svmtrain_mex.mex:     svmtrain_mex.cpp svm.h svm.o svm_model_matlab.o
	env CC=$(CXX) $(OCTMEX) svmtrain_mex.cpp svm.o svm_model_matlab.o

svmtrain_mex.$(MEX_EXT):     svmtrain_mex.cpp svm.h svm.o svm_model_matlab.o
	env CC=$(CXX) $(MATMEX) svmtrain_mex.cpp svm.o svm_model_matlab.o

svm_model_matlab.o:     svm_model_matlab.c svm.h
	$(CC) $(CFLAGS) -c svm_model_matlab.c

svm.o:  svm.cpp svm.h
	$(CXX) $(CFLAGS) -c svm.cpp

clean: ; -$(RM) *.o core octave-core *.oct *~ *.mex*
