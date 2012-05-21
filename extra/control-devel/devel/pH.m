%{
Contributed by:
	Jairo Espinosa
	K.U.Leuven ESAT-SISTA
	K.Mercierlaan 94
	B3001 Heverlee
	Jairo.Espinosa@esat.kuleuven.ac.be

Description:
	Simulation data of a pH neutralization process in a constant volume
	stirring tank. 
	Volume of the tank 1100 liters 
	Concentration of the acid solution (HAC) 0.0032 Mol/l
	Concentration of the base solution (NaOH) 0,05 Mol/l
Sampling:
	10 sec
Number:
	2001
Inputs:
	u1: Acid solution flow in liters
	u2: Base solution flow in liters

Outputs:
	y: pH of the solution in the tank

References:
	T.J. Mc Avoy, E.Hsu and S.Lowenthal, Dynamics of pH in controlled 
	stirred tank reactor, Ind.Eng.Chem.Process Des.Develop.11(1972)
	71-78

Properties:
	Highly non-linear system.

Columns:
	Column 1: time-steps
	Column 2: input u1
	Column 3: input u2
	Column 4: output y

Category:
	Process industry systems

%}

clear all, close all, clc

load pHdata.dat
U=pHdata(:,2:3);
Y=pHdata(:,4);


dat = iddata (Y, U)

[sys, x0] = moen4 (dat, 's', 15, 'n', 6)     % s=15, n=6


[y, t] = lsim (sys, U, [], x0);

err = norm (Y - y, 1) / norm (Y, 1)
st = isstable (sys)

figure (1)
plot (t, Y(:,1), 'b', t, y(:,1), 'r')



