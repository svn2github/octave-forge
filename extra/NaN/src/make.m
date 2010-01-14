% This make.m is used for Matlab under Windows

%	$Id$
%	Copyright (C) 2010 by Alois Schloegl <a.schloegl@ieee.org>
%       This function is part of the NaN-toolbox
%       http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/

% add -largeArrayDims on 64-bit machines

fprintf(1,'!!!!!!!\n\tPlease note, not all functions might compile. \n!!!!!!!\n')
mex covm_mex.cpp
mex sumskipnan_mex.cpp
mex histo_mex.cpp
mex -c svm.cpp
mex -c svm_model_matlab.c
mex -c tron.cpp
mex -c linear.cpp
mex -c linear_model_matlab.c
if strcmp(computer,'PCWIN')
	mex svmtrain_mex.cpp svm.obj svm_model_matlab.obj
	mex svmpredict_mex.cpp svm.obj svm_model_matlab.obj
	mex train.cpp tron.obj linear.obj linear_model_matlab.obj 
else
	mex svmtrain_mex.cpp svm.o svm_model_matlab.o 
	mex svmpredict_mex.cpp svm.o svm_model_matlab.o
	mex train.cpp tron.o linear.o linear_model_matlab.o 
end; 