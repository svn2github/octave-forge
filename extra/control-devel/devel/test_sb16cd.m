%{
 SB16CD EXAMPLE PROGRAM DATA (Continuous system)
  8  1  1   2   0.1E0  C  D  F  R  F
  
  N, M, P, NCR, TOL,
  DICO, JOBD, JOBMR, JOBCF, ORDSEL
  
         0    1.0000         0         0         0         0         0        0
         0         0         0         0         0         0         0        0
         0         0   -0.0150    0.7650         0         0         0        0
         0         0   -0.7650   -0.0150         0         0         0        0
         0         0         0         0   -0.0280    1.4100         0        0
         0         0         0         0   -1.4100   -0.0280         0        0
         0         0         0         0         0         0   -0.0400    1.850
         0         0         0         0         0         0   -1.8500   -0.040
    0.0260
   -0.2510
    0.0330
   -0.8860
   -4.0170
    0.1450
    3.6040
    0.2800
  -.996 -.105 0.261 .009 -.001 -.043 0.002 -0.026
  0.0
4.472135954999638e-002    6.610515358414598e-001    4.698598960657579e-003  3.601363251422058e-001    1.032530880771415e-001   -3.754055214487997e-002  -4.268536964759344e-002    3.287284547842979e-002
    4.108939884667451e-001
    8.684600000000012e-002
    3.852317308197148e-004
   -3.619366874815911e-003
   -8.803722876359955e-003
    8.420521094001852e-003
    1.234944428038507e-003
    4.263205617645322e-003
%}

a =  [       0    1.0000         0         0         0         0         0        0
             0         0         0         0         0         0         0        0
             0         0   -0.0150    0.7650         0         0         0        0
             0         0   -0.7650   -0.0150         0         0         0        0
             0         0         0         0   -0.0280    1.4100         0        0
             0         0         0         0   -1.4100   -0.0280         0        0
             0         0         0         0         0         0   -0.0400    1.850
             0         0         0         0         0         0   -1.8500   -0.040 ];

b =  [  0.0260
       -0.2510
        0.0330
       -0.8860
       -4.0170
        0.1450
        3.6040
        0.2800 ];

c =  [  -.996 -.105 0.261 .009 -.001 -.043 0.002 -0.026 ];

d =  [  0.0 ];

f = [  4.472135954999638e-002    6.610515358414598e-001    4.698598960657579e-003  3.601363251422058e-001    1.032530880771415e-001   -3.754055214487997e-002  -4.268536964759344e-002    3.287284547842979e-002 ];

g = [  4.108939884667451e-001
       8.684600000000012e-002
       3.852317308197148e-004
      -3.619366874815911e-003
      -8.803722876359955e-003
       8.420521094001852e-003
       1.234944428038507e-003
       4.263205617645322e-003 ];
       
%{
  8  1  1   2   0.1E0  C  D  F  R  F
  
  N, M, P, NCR, TOL,
  DICO, JOBD, JOBMR, JOBCF, ORDSEL
%}


tol = 0.1;  # tol1
dico = 0;
jobd = 1;
jobmr = 1;
jobcf = 1;
ordsel = 0;
ncr = 2;


[ac, bc, cc] = slsb16cd (a, b, c, d, dico, ncr, ordsel, jobd, jobmr, \
                             f, g, jobcf, tol)

Go = ss (a, b, c, d);
[Kr, Info] = fwcfconred (Go, f, g, 2, "method", "bfsr", "cf", "right")

%{
 SB16CD EXAMPLE PROGRAM RESULTS

 The order of reduced controller =  2

 The frequency-weighted Hankel singular values are:
   3.3073   0.7274   0.1124   0.0784   0.0242   0.0182   0.0101   0.0094

 The reduced controller state dynamics matrix Ac is 
  -0.4334   0.4884
  -0.1950  -0.1093

 The reduced controller input/state matrix Bc is 
  -0.4231
  -0.1785

 The reduced controller state/output matrix Cc is 
  -0.0326  -0.2307
%}