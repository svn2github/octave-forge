%{
This file describes the data in the erie.dat file.
1. Contributed by:
	Peter Van Overschee
	K.U.Leuven - ESAT - SISTA
	K. Mercierlaan 94
	3001 Heverlee
	Peter.Vanoverschee@esat.kuleuven.ac.be
2. Process/Description:
	Data of a simulation (not real !) related to the related to the
	identification of the western basin of Lake Erie. The series consists 
	of 4 series: 
		U_erie, Y_erie: 	without noise (original series)
		U_erie_n10, Y_erie_n10:	10 percent additive white noise
		U_erie_n20, Y_erie_n20: 20 percent additive white noise
		U_erie_n30, Y_erie_n30:	30 percent additive white noise
3. Sampling time 
	1 month
4. Number of samples: 
	57 samples
5. Inputs:
	a. water temperature
   	b. water conductivity
   	c. water alkalinity
   	d. NO3
   	e. total hardness
6. Outputs:
	a. dissolved oxigen
   	b. algae
7. References:
	R.P. Guidorzi, M.P. Losito, T. Muratori, On the last eigenvalue
   	test in the structural identification of linear multivariable
   	systems, Proceedings of the V European meeting on cybernetics and
   	systems research, Vienna, april 1980.
8. Known properties/peculiarities
	The considered period runs from march 1968 till november 1972.
9. Some MATLAB-code to retrieve the data
	!guzip erie.dat.Z
	load erie.dat
	U=erie(:,1:20);
	Y=erie(:,21:28);
	U_erie=U(:,1:5);
	U_erie_n10=U(:,6:10);
	U_erie_n20=U(:,11:15);	
	U_erie_n30=U(:,16:20);
	Y_erie=Y(:,1:2);
	Y_erie_n10=Y(:,3:4);
	Y_erie_n20=Y(:,5:6);
	Y_erie_n30=Y(:,7:8);
%}

clear all, close all, clc

% DaISy code is wrong,
% first column is sample number
load erie.dat
U=erie(:,2:21);
Y=erie(:,22:29);
U_erie=U(:,1:5);
U_erie_n10=U(:,6:10);
U_erie_n20=U(:,11:15);	
U_erie_n30=U(:,16:20);
Y_erie=Y(:,1:2);
Y_erie_n10=Y(:,3:4);
Y_erie_n20=Y(:,5:6);
Y_erie_n30=Y(:,7:8);

Y = {Y_erie; Y_erie_n10; Y_erie_n20; Y_erie_n30};
U = {U_erie; U_erie_n10; U_erie_n20; U_erie_n30};

dat = iddata (Y, U, [], 'inname', {'a. water temperature';
   	                               'b. water conductivity';
   	                               'c. water alkalinity';
   	                               'd. NO3';
   	                               'e. total hardness'}, \
   	                   'outname', {'a. dissolved oxygen';
   	                               'b. algae'})

% [sys, x0] = moen4 (dat, 's', 5, 'n', 4)    % s=5, n=4
[sys, x0] = moen4 (dat, 's', 5, 'n', 4, 'noise', 'k')    % s=5, n=4


x0=x0{1};

[y, t] = lsim (sys, [U_erie, Y_erie], [], x0);
%[y, t] = lsim (sys, U_erie, [], x0);
%[y, t] = lsim (sys, U_erie);

err = norm (Y_erie - y, 1) / norm (Y_erie, 1)

figure (1)
p = columns (Y_erie);
for k = 1 : p
  subplot (2, 1, k)
  plot (t, Y_erie(:,k), 'b', t, y(:,k), 'r')
endfor

legend ('y measured', 'y simulated', 'location', 'southeast')


