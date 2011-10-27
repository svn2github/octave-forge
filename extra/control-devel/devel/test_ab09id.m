% AB09ID EXAMPLE PROGRAM DATA (Continuous system)
%  3  1  1   6  1  0  0   2   0.0  0.0  0.0 0.1E0  0.0    C   S  S   F   L  S  F 

% N, M, P, NV, PV, NW, MW, NR,
% ALPHA, ALPHAC, ALPHAO, TOL1, TOL2,
% DICO, JOBC, JOBO, JOB, WEIGHT,
% EQUIL, ORDSEL


a =  [ -26.4000,    6.4023,    4.3868;
        32.0000,         0,         0;
              0,    8.0000,         0 ];

b =  [       16
              0
              0 ];

c =  [   9.2994     1.1624     0.1090 ];

d =  [        0 ];

av = [  -1.0000,         0,    4.0000,   -9.2994,   -1.1624,   -0.1090;
              0,    2.0000,         0,   -9.2994,   -1.1624,   -0.1090;
              0,         0,   -3.0000,   -9.2994,   -1.1624,   -0.1090;
        16.0000,   16.0000,   16.0000,  -26.4000,    6.4023,    4.3868;
              0,         0,         0,   32.0000,         0,         0;
              0,         0,         0,         0,    8.0000,         0 ];

bv = [        1
              1
              1
              0
              0
              0 ];

cv = [        1          1          1          0          0          0 ];

dv = [        0 ];

aw = bw = cw = dw = [];

alpha = alphac = alphao = 0.0;
tol1 = 0.1;
tol2 = 0.0;
dico = 0;
jobc = jobo = 0;
job = 1;
weight = 1;
equil = 0;
ordsel = 0;
nr = 2;


[ar, br, cr, dr] = slab09id (a, b, c, d, dico, equil, nr, ordsel, alpha, job, \
                             av, bv, cv, dv, \
                             aw, bw, cw, dw, \
                             weight, jobc, jobo, alphac, alphao, \
                             tol1, tol2)

%{
 AB09ID EXAMPLE PROGRAM RESULTS


 The order of reduced model =  2

 The Hankel singular values of weighted ALPHA-stable part are
   3.8253   0.2005

 The reduced state dynamics matrix Ar is 
   9.1900   0.0000
   0.0000 -34.5297

 The reduced input/state matrix Br is 
  11.9593
  16.9329

 The reduced state/output matrix Cr is 
   2.8955   6.9152

 The reduced input/output matrix Dr is 
   0.0000
%}