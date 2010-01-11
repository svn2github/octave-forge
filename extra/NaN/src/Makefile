
CC  	= gcc
CXX 	= g++
CFLAGS 	= -Wall -Wconversion -O3 -fPIC
OCTMEX	= mkoctfile --mex

MATLABDIR = /usr/local/matlab
MEX_OPTION = CC\#$(CXX) CXX\#$(CXX) CFLAGS\#"$(CFLAGS)" CXXFLAGS\#"$(CFLAGS)"
# comment the following line if you use MATLAB on 32-bit computer
MEX_OPTION += -largeArrayDims
MATMEX	= $(MATLABDIR)/bin/mex $(MEX_OPTION)



PROGS = histo_mex.mex covm_mex.mex sumskipnan_mex.mex train.mex svmtrain_mex.mex svmpredict_mex.mex

octave: $(PROGS)

MEX_EXT = $(shell $(MATLABDIR)/bin/mexext)
matlab: $(patsubst $(PROGS), %_mex.$(MEX_EXT), $(wildcard *.mex)) 

$(PROGS): Makefile

%.oct: %.cc
	mkoctfile $<

%.mex: %.cpp
	$(OCTMEX) $<           ## Octave
%.$(MEX_EXT): %.cpp
	$(MATMEX) $<           ## Matlab

svmtrain_mex.mex svmpredict_mex.mex:     svmtrain_mex.cpp svm.h svm.cpp svm_model_matlab.c
	$(CXX) $(CFLAGS) -I /usr/include/octave -c svm.cpp
	$(CXX) $(CFLAGS) -I /usr/include/octave -c svm_model_matlab.c
	env CC=$(CXX) $(OCTMEX) svmtrain_mex.cpp svm.o svm_model_matlab.o
	env CC=$(CXX) $(OCTMEX) svmpredict_mex.cpp svm.o svm_model_matlab.o

svmtrain_mex.$(MEX_EXT) svmpredict_mex.$(MEX_EXT):     svmtrain_mex.cpp svm.h svm.cpp svm_model_matlab.c
	$(CXX) $(CFLAGS) -I $(MATLABDIR)/extern/include -c svm.cpp
	$(CXX) $(CFLAGS) -I $(MATLABDIR)/extern/include -c svm_model_matlab.c
	$(MATMEX) svmtrain_mex.cpp svm.o svm_model_matlab.o
	$(MATMEX) svmpredict_mex.cpp svm.o svm_model_matlab.o

train.$(MEX_EXT) predict.$(MEX_EXT): train.c linear.h tron.o linear.o linear_model_matlab.c
	$(CXX) $(CFLAGS) -I $(MATLABDIR)/extern/include -c linear_model_matlab.c
	$(MATMEX) $(MEX_OPTION) -lblas train.c tron.o linear.o linear_model_matlab.o
	#$(MATMEX) $(MEX_OPTION) -lblas predict.c tron.o linear.o linear_model_matlab.o

train.mex predict.mex: train.c linear.h tron.o linear.o linear_model_matlab.c
	$(CXX) $(CFLAGS) -I /usr/include/octave -c linear_model_matlab.c
	env CC=$(CXX) $(OCTMEX) -lblas train.c tron.o linear.o linear_model_matlab.o
        #env CC=$(CXX) $(OCTMEX) -lblas predict.c tron.o linear.o linear_model_matlab.o

linear.o: linear.cpp linear.h
	$(CXX) $(CFLAGS) -c linear.cpp

tron.o: tron.cpp tron.h
	$(CXX) $(CFLAGS) -c tron.cpp



clean: ; -$(RM) *.o core octave-core *.oct *~ *.mex*
