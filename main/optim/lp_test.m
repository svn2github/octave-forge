page_screen_output = 0;
A1 = [-1 1 2 1 2 ; -1 2 3 1 1 ; -1 1 1 2 1 ];
B1 = [7;6;4];
F1 = [-2 4 7 1 5];
LB1 = [-Inf;0;0;0;0];
UB1 = [1;1;1;1;1]*Inf;
N1 = 3;
x1 = [-1;0;1;0;2];
sol1 = lp(F1,A1,B1,LB1,UB1,N1);
assert(x1,sol1,10*eps);

A2 = [2 1 2 ; 3 3 1];
B2 = [4 ; 3];
F2 = [4 1 1];
LB2 = [0;0;0];
UB2 = [1;1;1]*Inf;
N2 = 2;
x2 = [0;2/5;9/5];
sol2 = lp(F2,A2,B2,LB2,UB2,N2);
assert(x2,sol2,10*eps);

A3 = [2 1 1; 1 2 3; 2 2 1];
B3 = [2; 5; 6];
F3 = -[3 1 3]; 
LB3 = [0;0;0];
UB3 = [1;1;1]*Inf;
N3  = 0;
x3 = [1/5;0;8/5];
sol3 = lp(F3,A3,B3,LB3,UB3,N3);
assert(x3,sol3,10*eps);

% This problem is identical to the third problem 
% accept for the fact that the x3 = x3+10;    
A4  = A3;
B4  = [-8;-25;-4];
F4  = F3;
LB4 = [0;0;-10];
UB4 = [1;1;1]*Inf;
N4  = 0;
x4 = x3+[0;0;10];
sol4 = lp(F4,A4,B4,LB4,UB4,N4);
assert(x4,sol4,10*eps);

A5 = [1 0 1 -1 2 ; 0 1 2 2 1 ];
B5 = [5;9];
F5 = [2 1 3 -2 10];
LB5 = [0;0;0;0;0];
UB5 = [7;10;1;5;3];
N5 = 2;
sol5 = lp(F5,A5,B5,LB5,UB5,N5);
x5 = [7;1;1;3;0];
assert(x5,sol5,10*eps);
