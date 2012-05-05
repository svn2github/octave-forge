%{
This file describes the data in the powerplant.dat file.
1. Contributed by:
	Peter Van Overschee
	K.U.Leuven - ESAT - SISTA
	K. Mercierlaan 94
	3001 Heverlee
	Peter.Vanoverschee@esat.kuleuven.ac.be
2. Process/Description:
	data of a power plant (Pont-sur-Sambre (France)) of 120 MW
3. Sampling time 
	1228.8 sec
4. Number of samples: 
	200 samples
5. Inputs:
	1. gas flow
   	2. turbine valves opening
   	3. super heater spray flow
   	4. gas dampers
   	5. air flow
6. Outputs:
	1. steam pressure
   	2. main stem temperature
   	3. reheat steam temperature
7. References:
	a. R.P. Guidorzi, P. Rossi, Identification of a power plant from normal
   	operating records. Automatic control theory and applications (Canada,
   	Vol 2, pp 63-67, sept 1974.
	b. Moonen M., De Moor B., Vandenberghe L., Vandewalle J., On- and
	off-line identification of linear state-space models, International
	Journal of Control, Vol. 49, Jan. 1989, pp.219-232
8. Known properties/peculiarities
	
9. Some MATLAB-code to retrieve the data
	!gunzip powerplant.dat.Z
	load powerplant.dat
	U=powerplant(:,1:5);
	Y=powerplant(:,6:8);
	Yr=powerplant(:,9:11);

%}

 close all, clc

load powerplant.dat
U=powerplant(:,1:5);
Y=powerplant(:,6:8);
Yr=powerplant(:,9:11);

inname = {'gas flow',
          'turbine valves opening',
          'super heater spray flow',
          'gas dampers',
          'air flow'};

outname = {'steam pressure',
           'main steam temperature',
           'reheat steam temperature'};
           
tsam = 1228.8;

dat = iddata (Y, U, tsam, 'outname', outname, 'inname', inname)

[sys, x0] = ident_a (dat, 10, 8)     % s=10, n=8


[y, t] = lsim (sys, U, [], x0);

err = norm (Y - y, 1) / norm (Y, 1)

figure (1)
p = columns (Y);
for k = 1 : p
  subplot (3, 1, k)
  plot (t, Y(:,k), 'b', t, y(:,k), 'r')
endfor
%title ('DaISy: Power Plant')
%legend ('y measured', 'y simulated', 'location', 'southeast')

st = isstable (sys)

