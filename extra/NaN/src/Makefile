
CC  	= gcc
CXX 	= g++
CFLAGS 	= -Wall -Wconversion -O3 -fPIC
OCTMEX	= mkoctfile --mex

MATLABDIR = /usr/local/matlab
# comment the following line if you use MATLAB on 32-bit computer
MEX_OPTION += -largeArrayDims
MATMEX	= $(MATLABDIR)/bin/mex $(MEX_OPTION)
MEX_EXT = $(shell $(MATLABDIR)/bin/mexext)

PROGS = $(patsubst %_mex.cpp,%_mex.mex,$(wildcard *.cpp)) 
all: $(PROGS) matlab

$(PROGS): Makefile

matlab: $(patsubst %_mex.cpp,%_mex.$(MEX_EXT),$(wildcard *.cpp)) 

%.oct: %.cc
	mkoctfile $<

%.mex: %.cpp
	$(OCTMEX) $<           ## Octave
%.$(MEX_EXT): %.cpp
	$(MATMEX) $<           ## Matlab

svmtrain_mex.mex svmpredict_mex.mex:     svmtrain_mex.cpp svm.h
	$(CXX) $(CFLAGS) -I /usr/include/octave -c svm.cpp
	$(CC) $(CFLAGS)  -I /usr/include/octave -c svm_model_matlab.c
	env CC=$(CXX) $(OCTMEX) svmtrain_mex.cpp svm.o svm_model_matlab.o
	env CC=$(CXX) $(OCTMEX) svmpredict_mex.cpp svm.o svm_model_matlab.o

svmtrain_mex.$(MEX_EXT) svmpredict_mex.$(MEX_EXT):     svmtrain_mex.cpp svm.h
	$(CXX) $(CFLAGS) -I $(MATLABDIR)/extern/include -c svm.cpp
	$(CC) $(CFLAGS)  -I $(MATLABDIR)/extern/include -c svm_model_matlab.c
	$(MATMEX) svmtrain_mex.cpp svm.o svm_model_matlab.o
	$(MATMEX) svmpredict_mex.cpp svm.o svm_model_matlab.o

clean: ; -$(RM) *.o core octave-core *.oct *~ *.mex*
