%{
This file describes the data in the glassfurnace.dat file.
1. Contributed by:
	Peter Van Overschee
	K.U.Leuven - ESAT - SISTA
	K. Mercierlaan 94
	3001 Heverlee
	Peter.Vanoverschee@esat.kuleuven.ac.be
2. Process/Description:
	Data of a glassfurnace (Philips)
3. Sampling time 
	
4. Number of samples: 
	1247 samples
5. Inputs:
	a. heating input
   	b. cooling input
   	c. heating input
6. Outputs:
	a. 6 outputs from temperature sensors in a cross section of the 
	furnace
7. References:
	a. Van Overschee P., De Moor B., N4SID : Subspace Algorithms for 
	the Identification of Combined Deterministic-Stochastic Systems, 
	Automatica, Special Issue on Statistical Signal Processing and Control, 
	Vol. 30, No. 1, 1994, pp. 75-93
	b.  Van Overschee P., "Subspace identification : Theory, 
	Implementation, Application" , Ph.D. Thesis, K.U.Leuven, February 1995. 
8. Known properties/peculiarities
	
9. Some MATLAB-code to retrieve the data
	!gunzip glassfurnace.dat.Z
	load glassfurnace.dat
      T=glassfurnace(:,1);
	U=glassfurnace(:,2:4);
	Y=glassfurnace(:,5:10);

%}


clear all, close all, clc

load glassfurnace.dat
T=glassfurnace(:,1);
U=glassfurnace(:,2:4);
Y=glassfurnace(:,5:10);


dat = iddata (Y, U)

[sys, x0, info] = moen4 (dat, 's', 10, 'n', 5, 'noise', 'k')     % s=10, n=5


[y, t] = lsim (sys, [U, Y], [], x0);

err = norm (Y - y, 1) / norm (Y, 1)

figure (1)
p = columns (Y);
for k = 1 : p
  subplot (3, 2, k)
  plot (t, Y(:,k), 'b', t, y(:,k), 'r')
endfor
%title ('DaISy: Glass Furnace')
%legend ('y measured', 'y simulated', 'location', 'southeast')


