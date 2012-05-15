%{
Contributed by:
	Favoreel
	KULeuven
	Departement Electrotechniek ESAT/SISTA
Kardinaal Mercierlaan 94
B-3001 Leuven
Belgium
	wouter.favoreel@esat.kuleuven.ac.be
Description:
	Data from the mechanical construction of a CD player arm.  
	The inputs are the forces of the mechanical actuators
  	while the outputs are related to the tracking accuracy of the arm.
  	The data was measured in closed loop, and then through a two-step
  	procedure converted to open loop equivalent data
    	The inputs are highly colored.
Sampling:
Number:
	2048
Inputs:
	u: forces of the mechanical actuators
Outputs:
	y: tracking accuracy of the arm
References:
  	We are grateful to R. de Callafon of the
    	Mechanical Engineering Systems and Control group of Delft, who
    	provided us with these data.
	
	- Van Den Hof P., Schrama R.J.P., An Indirect Method for Transfer 
	  Function Estimation From Closed Loop Data. Automatica, Vol. 29, 
	  no. 6, pp. 1523-1527, 1993.

Properties: 
Columns:
	Column 1: input u1
	Column 2: input u2
	Column 1: output y1
	Column 2: output y2
Category:
	mechanical systems

%}

clear all, close all, clc

load CD_player_arm-1.dat
U=CD_player_arm_1(:,1:2);
Y=CD_player_arm_1(:,3:4);


dat = iddata (Y, U)

% [sys, x0] = ident (dat, 15, 8)     % s=15, n=8
sys = arx (dat, 4, 4)

%[y, t] = lsim (sys, U, [], x0);
%[y, t] = lsim (sys(:,1:2), U);

[A, B] = filtdata (sys);
%[A, B] = tfdata (sys);


y1 = filter (B{1,1}, A{1,1}, U(:,1)) + filter (B{1,2}, A{1,2}, U(:,2));
y2 = filter (B{2,1}, A{2,1}, U(:,1)) + filter (B{2,2}, A{2,2}, U(:,2));
y = [y1, y2];

t = 0:length(U)-1;

err = norm (Y - y, 1) / norm (Y, 1)

figure (1)
p = columns (Y);
for k = 1 : p
  subplot (2, 1, k)
  plot (t, Y(:,k), 'b', t, y(:,k), 'r')
endfor


