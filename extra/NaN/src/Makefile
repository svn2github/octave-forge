####################################################
# Copyright 2010 Alois Schloegl 
# This is part of the NaN-toolbox - a statistics and machine learning toolbox for data with and without missing values. 
# http://pub.ist.ac.at/~schloegl/matlab/NaN/
####################################################

### modify directories according to your needs 
INCOCTAVE = -I /usr/include/octave 
MATLABDIR = /usr/local/matlab
# comment the following line if you use MATLAB on 32-bit operating system
MEX_OPTION += -largeArrayDims

####################################################

CC  	= gcc
CXX 	= g++
CFLAGS 	= -Wall -Wconversion -O3 -fPIC
OCTMEX	= mkoctfile --mex

MEX_OPTION  = CC\#$(CXX) CXX\#$(CXX) CFLAGS\#"$(CFLAGS)" CXXFLAGS\#"$(CFLAGS)"
MATMEX	    = $(MATLABDIR)/bin/mex $(MEX_OPTION)

PROGS = histo_mex.mex covm_mex.mex kth_element.mex sumskipnan_mex.mex str2array.mex train.mex svmtrain_mex.mex svmpredict_mex.mex xptopen.mex

octave: $(PROGS)

MEX_EXT = $(shell $(MATLABDIR)/bin/mexext)
matlab: $(patsubst %.mex, %.$(MEX_EXT), $(PROGS))
all: $(PROGS) $(patsubst %.mex, %.$(MEX_EXT), $(PROGS))

$(PROGS): Makefile

%.oct: %.cc
	mkoctfile $<

%.mex: %.cpp
	$(OCTMEX) $<           ## Octave
%.$(MEX_EXT): %.cpp
	$(MATMEX) $<           ## Matlab

svmtrain_mex.mex svmpredict_mex.mex:     svmtrain_mex.cpp svm.h svm.cpp svm_model_matlab.c
	$(CXX) $(CFLAGS) $(INCOCTAVE) -c svm.cpp
	$(CC)  $(CFLAGS) $(INCOCTAVE) -c svm_model_matlab.c
	env CC=$(CXX) $(OCTMEX) svmtrain_mex.cpp svm.o svm_model_matlab.o
	env CC=$(CXX) $(OCTMEX) svmpredict_mex.cpp svm.o svm_model_matlab.o

svmtrain_mex.$(MEX_EXT) svmpredict_mex.$(MEX_EXT):     svmtrain_mex.cpp svm.h svm.cpp svm_model_matlab.c
	$(CXX) $(CFLAGS) -I $(MATLABDIR)/extern/include -c svm.cpp
	$(CC) $(CFLAGS) -I $(MATLABDIR)/extern/include -c svm_model_matlab.c
	$(MATMEX) svmtrain_mex.cpp svm.o svm_model_matlab.o
	$(MATMEX) svmpredict_mex.cpp svm.o svm_model_matlab.o

train.$(MEX_EXT) predict.$(MEX_EXT): train.c linear.h tron.o linear.o linear_model_matlab.c
	$(CC) $(CFLAGS) -I $(MATLABDIR)/extern/include -c linear_model_matlab.c
	$(MATMEX)  -lblas train.c tron.o linear.o linear_model_matlab.o 
	#$(MATMEX) -lblas predict.c tron.o linear.o linear_model_matlab.o

train.mex predict.mex: train.c linear.h tron.o linear.o linear_model_matlab.c
	$(CC) $(CFLAGS) $(INCOCTAVE) -c linear_model_matlab.c
	env CC=$(CXX) $(OCTMEX) -lblas train.c tron.o linear.o linear_model_matlab.o
	#env CC=$(CXX) $(OCTMEX) -lblas predict.c tron.o linear.o linear_model_matlab.o

linear.o: linear.cpp linear.h
	$(CXX) $(CFLAGS) -c linear.cpp

tron.o: tron.cpp tron.h
	$(CXX) $(CFLAGS) -c tron.cpp


clean: ; -$(RM) *.o core octave-core *.oct *~ *.mex*
