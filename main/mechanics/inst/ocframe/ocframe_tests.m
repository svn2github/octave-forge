## -*- texinfo -*-
## @deftypefn {Function File} {} ocframe_tests() 
## Various tests for the entire package.
## Test 1, 2 & 3 are simple beams (tested for reactions and internal forces)
## Test 4 & 5 are frames (tested for reactions)
## @end deftypefn
function [P,D,MemF]=ocframe_tests()
	ocframe_test_1()
	ocframe_test_2()
	ocframe_test_3()
	ocframe_test_4()
	ocframe_test_5()
end

function doAssert(value1, value2, tolerance)
	printf("benchmark = %.3f, expected value = %.3f diff = %.3f \n",value1,value2,abs(value1-value2))
	assert(abs(value1-value2)<tolerance)
endfunction

function ocframe_test_1()
	printf("2 span beam\n")
	#beam 2 span beam
	# L1 = 5 m, L2 = 5 m
	L1 = 5.0;
	L2 = L1;
	q = -10;
	joints=[0,0,1,1,0;
	L1,0,0,1,0;
	L1+L2,0,0,1,0];

	EIA=[210e9,23130*(10^-2)^4,84.5*(10^-2)^2];%IPE400

	members=[1,2,EIA;2,3,EIA];

	nodeloads=[];
	dist=[1,0,q,0,q,0,0,0;
		  2,0,q,0,q,0,0,0];
	point=[];

	[P,D,MemF]=SolveFrame(joints,members,nodeloads,dist,point);
	
	#test reactions
	doAssert(P(1,2), -0.375*L1*q,0.01)
	doAssert(P(2,2), -1.250*L1*q,0.01)
	doAssert(P(3,2), -0.375*L1*q,0.01)
	
	#testinternal forces
	#PlotDiagrams(joints,members,dist,point,MemF,"M");
	[x,M,S,N]=MSNForces(joints,members,dist,point,MemF,1,20);
	doAssert(min(M), 0.07*L1^2*q,0.01)
	doAssert(max(M), -0.125*L1^2*q,0.01)
	[x,M,S,N]=MSNForces(joints,members,dist,point,MemF,2,20);
	doAssert(min(M), 0.07*L1^2*q,0.01)
	doAssert(max(M), -0.125*L1^2*q,0.01)
endfunction

function ocframe_test_2()
	printf("2 span beam, loads splitted\n")
	#beam 2 span beam, loads splitted
	# L1 = 5 m, L2 = 5 m
	L1 = 5.0;
	L2 = L1;
	q = -10;
	joints=[0,0,1,1,0;
	L1,0,0,1,0;
	L1+L2,0,0,1,0];

	EIA=[210e9,23130*(10^-2)^4,84.5*(10^-2)^2];%IPE400

	members=[1,2,EIA;2,3,EIA];

	nodeloads=[];
	dist=[1,0,q,0,q,0,4,0;
	1,0,q,0,q,1,1,0;
	1,0,q,0,q,4,0,0;
	2,0,q,0,q,0,0,0];
	point=[];

	[P,D,MemF]=SolveFrame(joints,members,nodeloads,dist,point);
	
	#test reactions
	doAssert(P(1,2), -0.375*L1*q,0.01)
	doAssert(P(2,2), -1.250*L1*q,0.01)
	doAssert(P(3,2), -0.375*L1*q,0.01)
	
	#testinternal forces
	#PlotDiagrams(joints,members,dist,point,MemF,"M");
	[x,M,S,N]=MSNForces(joints,members,dist,point,MemF,1,20);
	doAssert(min(M), 0.07*L1^2*q,0.01)
	doAssert(max(M), -0.125*L1^2*q,0.01)
	[x,M,S,N]=MSNForces(joints,members,dist,point,MemF,2,20);
	doAssert(min(M), 0.07*L1^2*q,0.01)
	doAssert(max(M), -0.125*L1^2*q,0.01)
endfunction

function ocframe_test_3()
	printf("2 span beam, loads splitted and linear varied\n")
	#beam 2 span beam, loads splitted
	# L1 = 5 m, L2 = 5 m
	L1 = 5.0;
	L2 = L1;
	q = -10;
	joints=[0,0,1,1,0;
	L1,0,0,1,0;
	L1+L2,0,0,1,0];

	EIA=[210e9,23130*(10^-2)^4,84.5*(10^-2)^2];%IPE400

	members=[1,2,EIA;2,3,EIA];

	nodeloads=[];
	dist=[1,0,q*0,0,q,0,4,0;
	1,0,q*0,0,q,1,1,0;
	1,0,q*0,0,q,4,0,0;
	1,0,q,0,q*0,0,4,0;
	1,0,q,0,q*0,1,1,0;
	1,0,q,0,q*0,4,0,0;
	2,0,q,0,q,0,0,0];
	point=[];

	[P,D,MemF]=SolveFrame(joints,members,nodeloads,dist,point);
	
	#test reactions
	doAssert(P(1,2), -0.375*L1*q,0.01)
	doAssert(P(2,2), -1.250*L1*q,0.01)
	doAssert(P(3,2), -0.375*L1*q,0.01)
	
	#testinternal forces
	#PlotDiagrams(joints,members,dist,point,MemF,"M");
	[x,M,S,N]=MSNForces(joints,members,dist,point,MemF,1,20);
	doAssert(min(M), 0.07*L1^2*q,0.01)
	doAssert(max(M), -0.125*L1^2*q,0.01)
	[x,M,S,N]=MSNForces(joints,members,dist,point,MemF,2,20);
	doAssert(min(M), 0.07*L1^2*q,0.01)
	doAssert(max(M), -0.125*L1^2*q,0.01)
endfunction

function ocframe_test_4()
	printf("Frame from steel designers manual\n")
	#Steel Designers' Manual - 6th Edition Frame III page 1138
	
	#beam 2 span beam, loads splitted
	# L1 = 6 m, L2 = 6 m
	h = 4.0; #m
	f = 1.0; # m
	L = 8.0; # m
	s = sqrt(L * L / 4 + f * f); # m

	w = 10.0; # kN/m

	E = 200.0e6; # kPA
	I = 1.33e-4; # m^4
	A = 0.04e9; # m^2 original: 0.04 but deformation due to normal
				# force must be neglected

	phi = f / h;
	k = I / I * h / s;
	m = 1 + phi;
	K_1 = 2 * (k + 1 + m + m * m);
	K_2 = 2 * (k + phi * phi);
	C = 1 + 2 * m;
	R = phi * C - k;
	N_1 = K_1 * K_2 - R * R;

	EIA=[E,I,A];%IPE400
	
	joints = [0.0,0.0,1,1,1;
	0.0,h,0,0,0;
	L / 2.0, h + f, 0, 0, 0;
	L, h, 0, 0, 0;
	L, 0, 1,1,1];
	
	members=[1,2,EIA;
	2,3,EIA;
	3,4,EIA;
	4,5,EIA];

	nodeloads=[];
	q = -w * L / (2 * s); #projected load 
	dist=[2, 0.0, q, 0.0, q, 0.0, 0.0, 0;
		3, 0.0, q, 0.0, q, 0.0, 0.0, 0];
	point=[];

	[P,D,MemF]=SolveFrame(joints,members,nodeloads,dist,point);
	
	#test reactions
	
	M_A = w * L * L / 16 * (k * (8 + 15.0 * phi) + phi * (6 - phi)) / N_1;
	M_A=-1*M_A; # other sign convention
	doAssert(P(1,3), M_A,0.01)
	
	M_E = -M_A;
	doAssert(P(5,3), M_E,0.01)
	
	V_E = w * L / 2;
	V_A = V_E
	doAssert(P(1,2), V_A,0.01)
	doAssert(P(5,2), V_E,0.01)
	
	M_B = -w * L * L / 16 * (k * (16 + 15 * phi) + phi * phi) / N_1;
	M_A *= -1; # return to book's sign convention
	H_A = (M_A - M_B) / h;
	H_E = -H_A;
	
	doAssert(P(1,1), H_A,0.01)
	doAssert(P(5,1), H_E,0.01)
	
	doAssert(P(1,1), H_A,0.01)
	doAssert(P(5,1), H_E,0.01)
	
	M_B = -w*L^2/16*(k*(16+15*phi)+phi^2)/N_1;
	M_D = M_B;
	[x,M,S,N]=MSNForces(joints,members,dist,point,MemF,2,20);
	doAssert(M(1), -M_B, 0.01) # other sign convention
	
	# check value at C involves correctness of MSN functions for moments, 
	#fixed end forces for the cases, transformation from global load too local, etc.
	M_C = w*L^2/8 - phi*M_A +m*M_B;
	doAssert(M(columns(M)), -M_C, 0.01) # other sign convention
	
	#PlotDiagrams(joints,members,dist,point,MemF,"M");
endfunction

function ocframe_test_5()
	printf("Frame from steel designers manual\n")
	#Steel Designers' Manual - 6th Edition Frame III page 1138
	# same as the above test case but load as trapezoid and splitted
	#beam 2 span beam, loads splitted
	# L1 = 6 m, L2 = 6 m
	h = 4.0; #m
	f = 1.0; # m
	L = 8.0; # m
	s = sqrt(L * L / 4 + f * f); # m

	w = 10.0; # kN/m

	E = 200.0e6; # kPA
	I = 1.33e-4; # m^4
	A = 0.04e9; # m^2 original: 0.04 but deformation due to normal
				# force must be neglected

	phi = f / h;
	k = I / I * h / s;
	m = 1 + phi;
	K_1 = 2 * (k + 1 + m + m * m);
	K_2 = 2 * (k + phi * phi);
	C = 1 + 2 * m;
	R = phi * C - k;
	N_1 = K_1 * K_2 - R * R;

	EIA=[E,I,A];%IPE400
	
	joints = [0.0,0.0,1,1,1;
	0.0,h,0,0,0;
	L / 2.0, h + f, 0, 0, 0;
	L, h, 0, 0, 0;
	L, 0, 1,1,1];
	
	members=[1,2,EIA;
	2,3,EIA;
	3,4,EIA;
	4,5,EIA];

	nodeloads=[];
	q = -w * L / (2 * s); #projected load 
	
	# load on member 2 is sum of 2 trapezoid.
	# load on span 3 is splitted in three parts and sum off trapezoids.
	dist=[2, 0.0, q*0, 0.0, q, 0.0, 0.0, 0;
		2, 0.0, q, 0.0, q*0, 0.0, 0.0, 0;
	
		3, 0.0, q*0, 0.0, q*1/s, 0.0, s-1.0, 0;
		3, 0.0, q*1/s, 0.0, q*(s-1)/s, 1.0, 1.0, 0;
		3, 0.0, q*(s-1)/s, 0.0, q, s-1.0, 0.0, 0;
		
		3, 0.0, q, 0.0, q*(s-1)/s, 0.0, s-1.0, 0;
		3, 0.0, q*(s-1)/s, 0.0, q*1/s, 1.0, 1.0, 0;
		3, 0.0, q*1/s, 0.0, q*0, s-1.0, 0.0, 0];
	point=[];

	[P,D,MemF]=SolveFrame(joints,members,nodeloads,dist,point);
	#test reactions
	
	M_A = w * L * L / 16 * (k * (8 + 15.0 * phi) + phi * (6 - phi)) / N_1;
	M_A=-1*M_A; # other sign convention
	doAssert(P(1,3), M_A,0.01)
	
	M_E = -M_A;
	doAssert(P(5,3), M_E,0.01)
	
	V_E = w * L / 2;
	V_A = V_E;
	doAssert(P(1,2), V_A,0.01)
	doAssert(P(5,2), V_E,0.01)
	
	M_B = -w * L * L / 16 * (k * (16 + 15 * phi) + phi * phi) / N_1;
	M_A *= -1; # return to book's sign convention
	H_A = (M_A - M_B) / h;
	H_E = -H_A;
	
	doAssert(P(1,1), H_A,0.01)
	doAssert(P(5,1), H_E,0.01)
	
	M_B = -w*L^2/16*(k*(16+15*phi)+phi^2)/N_1;
	M_D = M_B;
	[x,M,S,N]=MSNForces(joints,members,dist,point,MemF,2,20);
	doAssert(M(1), -M_B, 0.01) # other sign convention
	
	# check value at C involves correctness of MSN functions for moments, 
	#fixed end forces for the cases, transformation from global load too local, etc.
	M_C = w*L^2/8 - phi*M_A +m*M_B;
	doAssert(M(columns(M)), -M_C, 0.01) # other sign convention
	
	#PlotDiagrams(joints,members,dist,point,MemF,"M");
endfunction
