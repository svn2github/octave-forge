page_screen_output = 0;
A1 = [-1 1 2 1 2 ; -1 2 3 1 1 ; -1 1 1 2 1 ];
B1 = [7;6;4];
F1 = [-2 4 7 1 5];
LB1 = [-Inf;0;0;0;0];
UB1 = Inf;
N1 = 3;
x1 = [-1;0;1;0;2];
sol1 = lp(F1,A1,B1,LB1,UB1,N1);
assert(sol1,x1,10*eps);

A2 = [2 1 2 ; 3 3 1];
B2 = [4 ; 3];
F2 = [4 1 1];
LB2 = 0;
UB2 = [];
N2 = 2;
x2 = [0;2/5;9/5];
sol2 = lp(F2,A2,B2,LB2,UB2,N2);
assert(sol2,x2,10*eps);

A3 = [2 1 1; 1 2 3; 2 2 1];
B3 = [2; 5; 6];
F3 = -[3 1 3]; 
LB3 = 0;
UB3 = [];
N3  = 0;
x3 = [1/5;0;8/5];
sol3 = lp(F3,A3,B3,LB3,UB3,N3);
assert(sol3,x3,10*eps);

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
assert(sol4,x4,10*eps);

A5 = [1 0 1 -1 2 ; 0 1 2 2 1 ];
B5 = [5;9];
F5 = [2 1 3 -2 10];
LB5 = [0;0;0;0;0];
UB5 = [7;10;1;5;3];
N5 = 2;
sol5 = lp(F5,A5,B5,LB5,UB5,N5);
x5 = [7;1;1;3;0];
assert(sol5,x5,10*eps);

F6 = [1 -.5 2];
A6 = [10 3 2; 2 3 4];
B6 = [1; 1];
LB6 = [-1 -1 -1];
UB6 = [1 1 1];
N6 = 0;
sol6 = lp(F6,A6,B6,LB6,UB6,N6);
x6 = [-1;1;-1];
assert(sol6,x6,10*eps);
