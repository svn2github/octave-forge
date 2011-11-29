%{
 SB16AD EXAMPLE PROGRAM DATA (Continuous system)
  3  1  1   3  2   0.0  0.1E0  0.0    C  S  S  F   I  N   F 

  N, M, P, NC, NCR, ALPHA, TOL1, TOL2, DICO,
  JOBC, JOBO, JOBMR, WEIGHT, EQUIL, ORDSEL
    
  -1.  0.   4.
   0.  2.   0.
   0.  0.  -3.
   1.
   1.
   1.
   1.  1.   1.
   0. 
  -26.4000    6.4023    4.3868
   32.0000         0         0
         0    8.0000         0
    -16
     0
     0
    9.2994    1.1624    0.1090
     0
%}

a =  [ -1.  0.   4.
        0.  2.   0.
        0.  0.  -3. ];

b =  [  1.
        1.
        1. ];

c =  [  1.  1.   1. ];

d =  [  0. ];

ac = [ -26.4000,    6.4023,    4.3868;
        32.0000,         0,         0;
              0,    8.0000,         0 ];

bc = [      -16
              0
              0 ];

cc = [   9.2994    1.1624    0.1090 ];

dc = [        0 ];


alpha = 0.0;
tol1 = 0.1;
tol2 = 0.0;
dico = 0;
jobc = jobo = 0;
jobmr = 1;
weight = 2;
equil = 1;
ordsel = 0;
ncr = 2;


[ar, br, cr, dr] = slsb16ad (a, b, c, d, dico, equil, ncr, ordsel, alpha, jobmr, \
                             ac, bc, cc, dc, weight, jobc, jobo, tol1, tol2)

%{
 SB16AD EXAMPLE PROGRAM RESULTS


 The order of reduced controller =  2

 The Hankel singular values of weighted ALPHA-stable part are
   3.8253   0.2005

 The reduced controller state dynamics matrix Ac is 
   9.1900   0.0000
   0.0000 -34.5297

 The reduced controller input/state matrix Bc is 
 -11.9593
  86.3137

 The reduced controller state/output matrix Cc is 
   2.8955  -1.3566

 The reduced controller input/output matrix Dc is 
   0.0000
%}