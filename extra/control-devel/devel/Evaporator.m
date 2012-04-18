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
	A four-stage evaporator to reduce the water content of a product, 
	for example milk. The 3 inputs are feed flow, vapor flow to the 
	first evaporator stage and cooling water flow. The three outputs 
	are the dry matter content, the flow and the temperature of the 
	outcoming product.
Sampling:
Number:
	6305
Inputs:
	u1: feed flow to the first evaporator stage
	u2: vapor flow to the first evaporator stage
	u3: cooling water flow
Outputs:
	y1: dry matter content
	y2: flow of the outcoming product
	y3: temperature of the outcoming product
References:
	- Zhu Y., Van Overschee P., De Moor B., Ljung L., Comparison of 
	  three classes of identification methods. Proc. of SYSID '94, 
	  Vol. 1, 4-6 July, Copenhagen, Denmark, pp.~175-180, 1994.
Properties:
Columns:
	Column 1: input u1
	Column 2: input u2
	Column 3: input u3
	Column 4: output y1
	Column 5: output y2
	Column 6: output y3
Category:
	Thermic systems
Where:

%}

clear all, close all, clc

load evaporator.dat
U=evaporator(:,1:3);
Y=evaporator(:,4:6);


dat = iddata (Y, U)

[sys, x0] = ident (dat, 10, 4)     % s=10, n=4


[y, t] = lsim (sys, U, [], x0);

err = norm (Y - y, 1) / norm (Y, 1)

figure (1)
p = columns (Y);
for k = 1 : p
  subplot (3, 1, k)
  plot (t, Y(:,k), 'b', t, y(:,k), 'r')
endfor


