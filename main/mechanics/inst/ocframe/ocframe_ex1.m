## -*- texinfo -*-
## @deftypefn {Function File} {} ocframe_ex1 () 
## Example of a planar frame.
##
## @end deftypefn
function [P,D,MemF]=ocframe_ex1()
	joints=[0,0,1,1,1;
			7.416,3,0,0,0;
			8+7.416,3,1,1,1];
	# first cells of each row are the x and y coordinates
	# next cells are the x, y and z constraints. 
	# node 1 and 3 are fully fixed, node 2 is free
	
	# member data
	E = 210.0e3; # N/mm^2 = MPa
	A = 6000;# mm^2
	I = 200.0e6;# mm^4
	
	# convert units to kN and m
	E = E*10^3;
	A = A*(10^-3)^2;
	I = I*(10^-3)^4,

	#connectivity data
	members=[1,2,E,I,A;
			2,3,E,I,A];

	# point load on node 2
	# Fx = 18.75 kN
	# Fy = -46.35 kN
	# Mz = 0 kNm
	nodeloads=[2, 18.75,-46.35, 0.0];
	
	loc = 1;
	glob = 0;
	
	# distributed load on member 2
	# Fx = 0 kN/m 
	# Fy = -4 kN/m
	# same for the end of the load
	# a = b = 0 m  load on full span
	# local load
	dist=[2,0,-4.0,0,-4.0,0.0,0.0,loc];
	#no point loads on members
	point=[];

	[P,D,MemF]=SolveFrame(joints,members,nodeloads,dist,point);
	#PlotFrame(joints,members,D,10);
	#plot moment diagram
	PlotDiagrams(joints,members,dist,point,MemF,"M");
end
