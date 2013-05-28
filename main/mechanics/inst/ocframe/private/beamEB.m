## Copyright (C) 2010 Johan Beke
##
## This software is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} beamEB() 
## Beam on an elastic bed. (Winkler)
## NOT READY YET!
## @end deftypefn

function [v,M,V] = beamEB(L, b, div, pointloads, distributedloads, E, I, k)
	#number of nodes
	NN = div + 1 + 4;
	#length of one division
	delta = L / div;
	#vector with the load (delta/2 at both size of the point)
	q = zeros(1, NN-1);

	#load the vector q
	x = delta/2;
	small= 10e-15;
	for i=1:NN-2
		#point loads are spread over the interval 
		for index=1:rows(pointloads)
			if (pointloads(index,1) < x + small && pointloads(index,1) > x - delta - small)
				q(i) = pointloads(index,2)/delta;
			endif
		endfor
		#dist loads
		for index=1:rows(distributedloads)
			#TODO: 
		endfor
		x+=delta;
	endfor
	# create and solve the system of finite differences
	A = zeros(NN,NN);
	B = zeros(NN,1);
	
	for node=3:NN-2
		#first 2 and last 2 node are dummy nodes for constraints
		if (node==3) # first node: M = 0 and V = 0
			# M = 0 = v" 
			A(node-1,node-1) = 1;
			A(node-1,node)   =-2;
			A(node-1,node+1) = 1;
			# V = 0 = v'''  
			# (using −1/2 	1 	0 	−1 	1/2 	: http://en.wikipedia.org/wiki/Finite_difference_coefficient)
			A(node-2,node-2) = -1/2;
			A(node-2,node-1) = 1;
			A(node-2,node) = 0;
			A(node-2,node+1) = -1;
			A(node-2,node+2) = 1/2;
		endif
		if (node == NN-2) # last node: M = 0 and V = 0
			# M = 0 = v" constraint on last row
			A(node+1,node-1) = 1;
			A(node+1,node)   =-2;
			A(node+1,node+1) = 1;
			# V = 0 = v''' constraint on row "node"  
			# (using −1/2 	1 	0 	−1 	1/2 	: http://en.wikipedia.org/wiki/Finite_difference_coefficient)
			A(node+2,node-2) = -1/2;
			A(node+2,node-1) = 1;
			A(node+2,node) = 0;
			A(node+2,node+1) = -1;
			A(node+2,node+2) = 1/2;
		endif
		# normal node:  EI v'''' + b k v = q
		# pattern for v'''' around node: 1 -4 6 -4 1
		# source: Abramowitz and Stegun
		A(node, node-2) = 1/delta^4;
		A(node, node-1) = -4/delta^4;
		A(node, node) = 6/delta^4 + b*k/(E*I);
		A(node, node+1) = -4/delta^4;
		A(node, node+2) = 1/delta^4;
		
		B(node,1) = q(node-2)/(E*I);
	endfor

	#solve with LU decomposition
	[L,U,P]=lu(A);
	v=inv(U)*inv(L)*B;

	#calculate moments and shear
	M = zeros(NN);
	V = zeros(NN);
	for node=3:NN-2
		# 1	-2	1
		M(node)=-E*I/(delta^2)*(v(node-1)-2*v(node)+v(node+1));
		# −1/2 	1 	0 	−1 	1/2
		V(node)=-E*I/(delta^3)*(-0.5*v(node-2)+v(node-1)-v(node+1)+0.5*v(node+2));
	endfor
	#delete dummy node at output
	v = v(3:NN-2);
	M = M(3:NN-2);
	V = V(3:NN-2);
endfunction

#[v,M,V]=beamEB(15,1,500,[3,500;6.50,800],[],30.0e6, 1*1.077^3/12, 20.0e-3/0.01^3);

