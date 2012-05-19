%{
This file describes the data in the destill.dat file.
1. Contributed by:
	Peter Van Overschee
	K.U.Leuven - ESAT - SISTA
	K. Mercierlaan 94
	3001 Heverlee
	Peter.Vanoverschee@esat.kuleuven.ac.be
2. Process/Description:
	Data of a simulation (not real !) related to the identification
   	of an ethane-ethylene destillationcolumn. The series consists of 4
	series: 
		U_dest, Y_dest: 	without noise (original series)
		U_dest_n10, Y_dest_n10:	10 percent additive white noise
		U_dest_n20, Y_dest_n20: 20 percent additive white noise
		U_dest_n30, Y_dest_n30:	30 percent additive white noise
3. Sampling time 
	15 min.
4. Number of samples: 
	90 samples
5. Inputs:
	a. ratio between the reboiler duty and the feed flow
   	b. ratio between the reflux rate and the feed flow
   	c. ratio between the distillate and the feed flow
   	d. input ethane composition
   	e. top pressure
6. Outputs:
	a. top ethane composition
	b. bottom ethylene composition
   	c. top-bottom differential pressure.
7. References:
	R.P. Guidorzi, M.P. Losito, T. Muratori, The range error test in the
	structural identification of linear multivariable systems,
   	IEEE transactions on automatic control, Vol AC-27, pp 1044-1054, oct.
   	1982.
8. Known properties/peculiarities
	
9. Some MATLAB-code to retrieve the data
	!gunzip destill.dat.Z
	load destill.dat
	U=destill(:,1:20);
	Y=destill(:,21:32);
	U_dest=U(:,1:5);
	U_dest_n10=U(:,6:10);
	U_dest_n20=U(:,11:15);	
	U_dest_n30=U(:,16:20);
	Y_dest=Y(:,1:3);
	Y_dest_n10=Y(:,4:6);
	Y_dest_n20=Y(:,7:9);
	Y_dest_n30=Y(:,10:12);
%}

clear all, close all, clc

% DaISy code is wrong,
% first column is sample number
load destill.dat
U=destill(:,2:21);
Y=destill(:,22:33);
U_dest=U(:,1:5);
U_dest_n10=U(:,6:10);
U_dest_n20=U(:,11:15);	
U_dest_n30=U(:,16:20);
Y_dest=Y(:,1:3);
Y_dest_n10=Y(:,4:6);
Y_dest_n20=Y(:,7:9);
Y_dest_n30=Y(:,10:12);

Y = {Y_dest; Y_dest_n10; Y_dest_n20; Y_dest_n30};
U = {U_dest; U_dest_n10; U_dest_n20; U_dest_n30};

dat = iddata (Y, U)

[sys, x0] = ident (dat, 5, 4)    % s=5, n=4
sys2 = arx (dat, 4, 4);

x0=x0{1};

[y, t] = lsim (sys, U_dest, [], x0);
[y2, t2] = lsim (sys(:, 1:5), U_dest);

% ARX has no initial conditions, therefore the bad results

err = norm (Y_dest - y, 1) / norm (Y_dest, 1)
err2 = norm (Y_dest - y2, 1) / norm (Y_dest, 1)

figure (1)
%plot (t, Y_dest, 'b')
plot (t, Y_dest, t, y, t, y2)
legend ('y measured', 'y MOEN4', 'y ARX', 'location', 'southeast')


