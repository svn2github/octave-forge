#!/usr/local/bin/octave -qH


%addpath('/home/abarth/Octave/octave-forge/extra/cgi/inst/');
addpath('/home/abarth/Octave/cgi/');

CGI = cgi();
CGI.form.y

%AA = fscanf(stdin,'%s',54)
%whos AA
%[AA,count] = scanf('%c',10)
