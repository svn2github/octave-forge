## Copyright (C) 2013 Johan Beke
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
## @deftypefn {Function File} {[@var{xcoord},@var{v},@var{M},@var{V}] =} beamEB (@var{L}, @var{b}, @var{div}, @var{pointloads}, @var{distributedloads}, @var{E}, @var{I}, @var{k}) 
##
##
## The finite difference method is used to solve the beam differential equation
## of a beam on an elastic bedding: v'''' + b*k*v/EI = p/EI
##
## INPUT:
##
## 	@var{L}: length of the beam
##
## 	@var{b}: width of the beam
##
## 	@var{div}: number of divisions
##
## 	@var{pointloads}: list of point loads [position from begin, load; ...]
## 	positive load is downwards
##
## 	@var{distributedloads}: list of distributed loads [a, q1, b, q2 ; ...]
## 	a: start of load (position from begin)
## 	b: end of load (position from begin)
## 	q1 and q2: load and start and begin
##
## 	@var{E}: modulus of elasticity
##
## 	@var{I}: moment of inertia
##
## 	@var{k}: bedding constant
## 
##
## OUTPUT:
##
## 	@var{xcoord}: x coordinate of the results
##
## 	@var{v}: displacement at x
##
## 	@var{M}: moment at x
##
## 	@var{V}: shear forces at x
##
## NOTE: units must be compatible for all variables
## @end deftypefn

function [xcoord,v,M,V] = beamEB(L, b, div, pointloads, distributedloads, E, I, k)
	#number of nodes
	NN = div + 1 + 4; # one node extra for divisions. 2 extra at each side for end constraints
	#length of one division
	delta = L / div;
	#vector with the load function
	q = zeros(1, NN);
	#x coordinates of the results
	xcoord = zeros(1, NN);
	#load the vector q
	x1 = 0;
	x2 = delta;
	
	small= 10e-15;
	
	for i=3:NN-2
		#point loads
		xcoord(i) = x1;
		for index=1:rows(pointloads)
			x = pointloads(index,1);
			if (x1 - small < x && x < x2 + small )
				#point load between node i and i+1
				#load divide proportional over the nodes
				q(i) = pointloads(index,2) * (x2-x)/delta;
				q(i+1) = pointloads(index,2) * (x-x1)/delta;
			endif
		endfor
		#dist loads
		for index=1:rows(distributedloads)
			if (distributedloads(index,1) > x - delta - small && distributedloads(index,3) < x + small )
				# point lays in the distributed load
				# TODO: complete
			endif
		endfor
		x1+=delta;
		x2+=delta;
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
			# (using −1/2 1 0 −1 1/2: http://en.wikipedia.org/wiki/Finite_difference_coefficient)
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
			# (using −1/2 1 0 −1 1/2: http://en.wikipedia.org/wiki/Finite_difference_coefficient)
			A(node+2,node-2) = -1/2;
			A(node+2,node-1) = 1;
			A(node+2,node) = 0;
			A(node+2,node+1) = -1;
			A(node+2,node+2) = 1/2;
		endif
		# normal node:  EI v'''' + b k v = q
		# pattern for v'''' around node: 1 -4 6 -4 1
		# source: Abramowitz and Stegun
		A(node, node-2) = 1/delta^4*delta;
		A(node, node-1) = -4/delta^4*delta;
		A(node, node) = (6/delta^4 + b*k/(E*I))*delta;
		A(node, node+1) = -4/delta^4*delta;
		A(node, node+2) = 1/delta^4*delta;
		
		B(node,1) = q(node-2)/(E*I);
	endfor

	#solve with LU decomposition
	#TODO: check why singular for large number of divisions
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
	xcoord = xcoord(3:NN-2);
endfunction

#[x,v,M,V]=beamEB(15,1,500,[3,500;6.50,800],[],30.0e6, 1*1.077^3/12, 20.0e-3/0.01^3); # from berekeningvanconstructies.be

