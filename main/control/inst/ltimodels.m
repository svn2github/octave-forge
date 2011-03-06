## Copyright (C) 2009          Luca Favatella
## Copyright (C) 2009, 2010   Lukas Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} test ltimodels
## @deftypefnx {Function File} ltimodels
## @deftypefnx {Function File} ltimodels (@var{systype})
## Test suite and help for LTI models.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2009
## Version: 0.2

function ltimodels (systype = "general")

  %if (nargin > 1)
    print_usage ();
  %endif

  ## TODO: write documentation

  if (! ischar (systype))
    error ("ltimodels: argument must be a string");
  endif

  systype = lower (systype);

  switch (systype)
    case "ss"
      str = {"State Space (SS) Models"\
             "-----------------------"\
             ""};

    case "tf"
      str = {"Transfer Function (TF) Models"\
             "-----------------------------"\
             ""};

    otherwise  # general
      str = {"Linear Time Invariant (LTI) Models"\
             "----------------------------------"\
             ""};

  endswitch

  disp ("");
  disp (char (str));

endfunction



## ==============================================================================
## LTI Tests
## ==============================================================================

## isct, isdt
%!shared ltisys
%! ltisys = tf (12);
%!assert (ltisys.ts, -2);
%!assert (isct (ltisys));
%!assert (isdt (ltisys));

%!shared ltisys
%! ltisys = ss (17);
%!assert (ltisys.ts, -2);
%!assert (isct (ltisys));
%!assert (isdt (ltisys));

%!shared ltisys
%! ltisys = tf (1, [1 1]);
%!assert (ltisys.ts, 0);
%!assert (isct (ltisys));
%!assert (! isdt (ltisys));

%!shared ltisys, ts
%! ts = 0.1;
%! ltisys = ss (-1, 1, 1, 0, ts);
%!assert (ltisys.ts, ts);
%!assert (! isct (ltisys));
%!assert (isdt (ltisys));


## lti: subsref
%!shared a
%! s = tf ("s");
%! G = (s+1)*s*5/(s+1)/(s^2+s+1);
%! a = G(1,1).num{1,1}(1);
%!assert (a, 5, 1e-4);



## ==============================================================================
## TF Tests
## ==============================================================================

## tf: minreal
%!shared a, b, c, d
%! s = tf ("s");
%! G1 = (s+1)*s*5/(s+1)/(s^2+s+1);
%! G2 = tf ([1, 1, 1], [2, 2, 2]);
%! G1min = minreal (G1);
%! G2min = minreal (G2);
%! a = G1min.num{1, 1};
%! b = G1min.den{1, 1};
%! c = G2min.num{1, 1};
%! d = G2min.den{1, 1};
%!assert (a, [5, 0], 1e-4);
%!assert (b, [1, 1, 1], 1e-4);
%!assert (c, 0.5, 1e-4);
%!assert (d, 1, 1e-4);



## ==============================================================================
## SS Tests
## ==============================================================================

## norm ct
%!shared H2, Hinf
%! sys = ss (-1, 1, 1, 0);
%! H2 = norm (sys, 2);
%! Hinf = norm (sys, inf);
%!assert (H2, 0.7071, 1.5e-5);
%!assert (Hinf, 1, 5e-4);


## norm dt
%!shared H2, Hinf
%! a = [ 2.417   -1.002    0.5488
%!           2        0         0
%!           0      0.5         0 ];
%! b = [     1
%!           0
%!           0 ];
%! c = [-0.424    0.436   -0.4552 ];
%! d = [     1 ];
%! sys = ss (a, b, c, d, 0.1);
%! H2 = norm (sys, 2);
%! Hinf = norm (sys, inf);
%!assert (H2, 1.2527, 1.5e-5);
%!assert (Hinf, 2.7, 0.1);


## transmission zeros of state-space models
##
## Results from the "Dark Side" 7.5 and 7.8
##
##  -13.2759
##   12.5774
##  -0.0155
##
## Results from Scilab 5.2.0b1 (trzeros)
##
##  - 13.275931  
##    12.577369  
##  - 0.0155265
##
%!shared z, z_exp
%! A = [   -0.7   -0.0458     -12.2        0
%!            0    -0.014   -0.2904   -0.562
%!            1   -0.0057      -1.4        0
%!            1         0         0        0 ];
%!
%! B = [  -19.1      -3.1
%!      -0.0119   -0.0096
%!        -0.14     -0.72
%!            0         0 ];
%!
%! C = [      0         0        -1        1
%!            0         0     0.733        0 ];
%!
%! D = [      0         0
%!       0.0768    0.1134 ];
%!
%! sys = ss (A, B, C, D);
%! z = sort (zero (sys));
%!
%! z_exp = sort ([-13.2759; 12.5774; -0.0155]);
%!
%!assert (z, z_exp, 1e-4);


## transmission zeros of descriptor state-space models
%!shared z, z_exp
%! A = [  1     0     0     0     0     0     0     0     0
%!        0     1     0     0     0     0     0     0     0
%!        0     0     1     0     0     0     0     0     0
%!        0     0     0     1     0     0     0     0     0
%!        0     0     0     0     1     0     0     0     0
%!        0     0     0     0     0     1     0     0     0
%!        0     0     0     0     0     0     1     0     0
%!        0     0     0     0     0     0     0     1     0
%!        0     0     0     0     0     0     0     0     1 ];
%!
%! E = [  0     0     0     0     0     0     0     0     0
%!        1     0     0     0     0     0     0     0     0
%!        0     1     0     0     0     0     0     0     0
%!        0     0     0     0     0     0     0     0     0
%!        0     0     0     1     0     0     0     0     0
%!        0     0     0     0     1     0     0     0     0
%!        0     0     0     0     0     0     0     0     0
%!        0     0     0     0     0     0     1     0     0
%!        0     0     0     0     0     0     0     1     0 ];
%!
%! B = [ -1     0     0
%!        0     0     0
%!        0     0     0
%!        0    -1     0
%!        0     0     0
%!        0     0     0
%!        0     0    -1
%!        0     0     0
%!        0     0     0 ];
%!
%! C = [  0     1     1     0     3     4     0     0     2
%!        0     1     0     0     4     0     0     2     0
%!        0     0     1     0    -1     4     0    -2     2 ];
%!
%! D = [  1     2    -2
%!        0    -1    -2
%!        0     0     0 ];
%!
%! sys = dss (A, B, C, D, E);
%! z = zero (sys);
%!
%! z_exp = 1;
%!
%!assert (z, z_exp, 1e-4);


## ss: minreal (SLICOT TB01PD)
%!shared C, D
%!
%! A = ss (-2, 3, 4, 5);
%! B = A / A;
%! C = minreal (B, 1e-15);
%! D = ss (1);
%!
%!assert (C.a, D.a);
%!assert (C.b, D.b);
%!assert (C.c, D.c);
%!assert (C.d, D.d);

%!shared M, Me
%! A = [ 1.0   2.0   0.0
%!       4.0  -1.0   0.0
%!       0.0   0.0   1.0 ];
%!
%! B = [ 1.0
%!       0.0
%!       1.0 ];
%!
%! C = [ 0.0   1.0  -1.0
%!       0.0   0.0   1.0 ];
%!
%! D = zeros (2, 1);
%!
%! sys = ss (A, B, C, D);
%! sysmin = minreal (sys, 0.0);
%! [Ar, Br, Cr, Dr] = ssdata (sysmin);
%! M = [Ar, Br; Cr, Dr];
%!
%! Ae = [ 1.0000  -1.4142   1.4142
%!       -2.8284   0.0000   1.0000
%!        2.8284   1.0000   0.0000 ];
%!
%! Be = [-1.0000
%!        0.7071
%!        0.7071 ];
%!
%! Ce = [ 0.0000   0.0000  -1.4142
%!        0.0000   0.7071   0.7071 ];
%!
%! De = zeros (2, 1);
%!
%! Me = [Ae, Be; Ce, De];
%!
%!assert (M, Me, 1e-4);


## dss: minreal (SLICOT TG01JD)
%!shared Ar, Br, Cr, Dr, Er, Ae, Be, Ce, De, Ee
%! A = [ -2    -3     0     0     0     0     0     0     0
%!        1     0     0     0     0     0     0     0     0
%!        0     0    -2    -3     0     0     0     0     0
%!        0     0     1     0     0     0     0     0     0
%!        0     0     0     0     1     0     0     0     0
%!        0     0     0     0     0     1     0     0     0
%!        0     0     0     0     0     0     1     0     0
%!        0     0     0     0     0     0     0     1     0
%!        0     0     0     0     0     0     0     0     1 ];
%!
%! E = [  1     0     0     0     0     0     0     0     0
%!        0     1     0     0     0     0     0     0     0
%!        0     0     1     0     0     0     0     0     0
%!        0     0     0     1     0     0     0     0     0
%!        0     0     0     0     0     0     0     0     0
%!        0     0     0     0     1     0     0     0     0
%!        0     0     0     0     0     0     0     0     0
%!        0     0     0     0     0     0     1     0     0
%!        0     0     0     0     0     0     0     1     0 ];
%!
%! B = [  1     0
%!        0     0
%!        0     1
%!        0     0
%!       -1     0
%!        0     0
%!        0    -1
%!        0     0
%!        0     0 ];
%!
%! C = [  1     0     1    -3     0     1     0     2     0
%!        0     1     1     3     0     1     0     0     1 ];
%!
%! D = zeros (2, 2);
%!
%! sys = dss (A, B, C, D, E);
%! sysmin = minreal (sys, 0.0);
%! [Ar, Br, Cr, Dr, Er] = dssdata (sysmin);
%!
%! Ae = [  1.0000  -0.0393  -0.0980  -0.1066   0.0781  -0.2330   0.0777
%!         0.0000   1.0312   0.2717   0.2609  -0.1533   0.6758  -0.3553
%!         0.0000   0.0000   1.3887   0.6699  -0.4281   1.6389  -0.7615
%!         0.0000   0.0000   0.0000  -1.2147   0.2423  -0.9792   0.4788
%!         0.0000   0.0000   0.0000   0.0000  -1.0545   0.5035  -0.2788
%!         0.0000   0.0000   0.0000   0.0000   0.0000   1.6355  -0.4323
%!         0.0000   0.0000   0.0000   0.0000   0.0000   0.0000   1.0000 ];
%!
%! Ee = [  0.4100   0.2590   0.5080  -0.3109   0.0705   0.1429  -0.1477
%!        -0.7629  -0.3464   0.0992  -0.3007   0.0619   0.2483  -0.0152
%!         0.1120  -0.2124  -0.4184  -0.1288   0.0569  -0.4213  -0.6182
%!         0.0000   0.1122  -0.0039   0.2771  -0.0758   0.0975   0.3923
%!         0.0000   0.0000   0.3708  -0.4290   0.1006   0.1402  -0.2699
%!         0.0000   0.0000   0.0000   0.0000   0.9458  -0.2211   0.2378
%!         0.0000   0.0000   0.0000   0.5711   0.2648   0.5948  -0.5000 ];
%!
%! Be = [ -0.5597   0.2363
%!        -0.4843  -0.0498
%!        -0.4727  -0.1491
%!         0.1802   1.1574
%!         0.5995   0.1556
%!        -0.1729  -0.3999
%!         0.0000   0.2500 ];
%!
%! Ce = [  0.0000   0.0000   0.0000   0.0000   0.0000   0.0000   4.0000
%!         0.0000   0.0000   0.0000   0.0000   0.0000   3.1524  -1.7500 ];
%!
%! De = zeros (2, 2);
%!
%!assert (Ar, Ae, 1e-4);
%!assert (Br, Be, 1e-4);
%!assert (Cr, Ce, 1e-4);
%!assert (Dr, De, 1e-4);
%!assert (Er, Ee, 1e-4);


## ss: sminreal
%!shared B, C
%!
%! A = ss (-2, 3, 4, 5);
%! B = A / A;
%! C = sminreal (B);  # no states should be removed
%!
%!assert (C.a, B.a);
%!assert (C.b, B.b);
%!assert (C.c, B.c);
%!assert (C.d, B.d);

%!shared A, B, D, E
%!
%! A = ss (-1, 1, 1, 0);
%! B = ss (-2, 3, 4, 5);
%! C = [A, B];
%! D = sminreal (C(:, 1));
%! E = sminreal (C(:, 2));
%!
%!assert (D.a, A.a);
%!assert (D.b, A.b);
%!assert (D.c, A.c);
%!assert (D.d, A.d);
%!assert (E.a, B.a);
%!assert (E.b, B.b);
%!assert (E.c, B.c);
%!assert (E.d, B.d);


## mtimes
%!shared sysmat, sysmat_exp
%! sys1 = ss ([0, 1; -3, -2], [0; 1], [-5, 1], [2]);
%! sys2 = ss ([-10], [1], [-40], [5]);
%! sys3 = sys2 * sys1;
%! [A, B, C, D] = ssdata (sys3);
%! sysmat = [A, B; C, D];
%! A_exp = [ -10   -5    1
%!             0    0    1
%!             0   -3   -2 ];
%! B_exp = [   2
%!             0
%!             1 ];
%! C_exp = [ -40  -25    5 ];
%! D_exp = [  10 ];
%! sysmat_exp = [A_exp, B_exp; C_exp, D_exp];
%!assert (sysmat, sysmat_exp)


## inverse of state-space models
## test from SLICOT AB07ND
## result differs intentionally from a commercial
## implementation of an octave-like language
%!shared M, Me
%! A = [ 1.0   2.0   0.0
%!       4.0  -1.0   0.0
%!       0.0   0.0   1.0 ];
%!
%! B = [ 1.0   0.0
%!       0.0   1.0
%!       1.0   0.0 ];
%!
%! C = [ 0.0   1.0  -1.0
%!       0.0   0.0   1.0 ];
%!
%! D = [ 4.0   0.0
%!       0.0   1.0 ];
%!
%! sys = ss (A, B, C, D);
%! sysinv = inv (sys);
%! [Ai, Bi, Ci, Di] = ssdata (sysinv);
%! M = [Ai, Bi; Ci, Di];
%!
%! Ae = [ 1.0000   1.7500   0.2500
%!        4.0000  -1.0000  -1.0000
%!        0.0000  -0.2500   1.2500 ];
%!
%! Be = [-0.2500   0.0000
%!        0.0000  -1.0000
%!       -0.2500   0.0000 ];
%!
%! Ce = [ 0.0000   0.2500  -0.2500
%!        0.0000   0.0000   1.0000 ];
%!
%! De = [ 0.2500   0.0000
%!        0.0000   1.0000 ];
%!
%! Me = [Ae, Be; Ce, De];  # Me = [Ae, -Be; -Ce, De];
%!
%!assert (M, Me, 1e-4);


## sensitivity function
## Note the correct physical meaning of the states.
## Test would fail on a commercial octave clone
## because of wrong signs of matrices B and C.
## NOTE: Don't use T = I - S for complementary sensitivity,
##       use T = feedback (L) instead!
%!shared S1, S2
%! P = ss (-2, 3, 4, 5);  # meaningless numbers
%! C = ss (-1, 1, 1, 0);  # ditto
%! L = P * C;
%! I = eye (size (L));
%! S1 = feedback (I, L*-I, "+");  # draw a block diagram for better understanding
%! S2 = inv (I + L);
%!assert (S1.a, S2.a, 1e-4);
%!assert (S1.b, S2.b, 1e-4);
%!assert (S1.c, S2.c, 1e-4);
%!assert (S1.d, S2.d, 1e-4);


## staircase (SLICOT AB01OD)
%!shared Ac, Bc, Ace, Bce
%! A = [ 17.0   24.0    1.0    8.0   15.0
%!       23.0    5.0    7.0   14.0   16.0
%!        4.0    6.0   13.0   20.0   22.0
%!       10.0   12.0   19.0   21.0    3.0
%!       11.0   18.0   25.0    2.0    9.0 ];
%!
%! B = [ -1.0   -4.0
%!        4.0    9.0
%!       -9.0  -16.0
%!       16.0   25.0
%!      -25.0  -36.0 ];
%!
%! tol = 0;
%!
%! A = A.';  # There's a little mistake in the example
%!           # program of routine AB01OD in SLICOT 5.0
%!
%! [Ac, Bc, U, ncont] = slab01od (A, B, tol);
%!
%! Ace = [ 12.8848   3.2345  11.8211   3.3758  -0.8982
%!          4.4741 -12.5544   5.3509   5.9403   1.4360
%!         14.4576   7.6855  23.1452  26.3872 -29.9557
%!          0.0000   1.4805  27.4668  22.6564  -0.0072
%!          0.0000   0.0000 -30.4822   0.6745  18.8680 ];
%!
%! Bce = [ 31.1199  47.6865
%!          3.2480   0.0000
%!          0.0000   0.0000
%!          0.0000   0.0000
%!          0.0000   0.0000 ];
%!
%!assert (Ac, Ace, 1e-4);
%!assert (Bc, Bce, 1e-4);


## controllability staircase form of descriptor state-space models (SLICOT TG01HD)
%!shared ac, ec, bc, cc, q, z, ncont, ac_e, ec_e, bc_e, cc_e, q_e, z_e, ncont_e
%!
%! a = [ 2     0     2     0    -1     3     1
%!       0     1     0     0     1     0     0
%!       0     0     0     1     0     0     1
%!       0     0     2     0    -1     3     1
%!       0     0     0     1     0     0     1
%!       0     1     0     0     1     0     0
%!       0     0     0     1     0     0     1 ];
%!
%! e = [ 0     0     1     0     0     0     0
%!       0     0     0     0     0     1     0
%!       0     0     0     0     0     0     1
%!       0     0     0     0     0     0     1
%!       0     0     0     1     0     0     0
%!       0     0     1     0    -1     0     0
%!       1     3     0     2     0     0     0 ];
%!
%! b = [ 2     1     0
%!       0     0     0
%!       0     0     0
%!       0     0     0
%!       0     0     0
%!       0     0     0
%!       1     2     3 ];
%!
%! c = [ 1     0     0     1     0     0     1
%!       0    -1     1     0    -1     1     0 ];
%!
%! tol = 0;
%!
%! [ac, ec, bc, cc, q, z, ncont] = sltg01hd (a, e, b, c, tol);
%!
%! ncont_e = 3;
%!
%! ac_e = [  0.0000   0.0000   0.0000   0.0000  -1.2627   0.4334   0.4666
%!           0.0000   2.0000   0.0000  -3.7417  -0.8520   0.2924  -0.4342
%!           0.0000   0.0000   1.7862   0.3780  -0.2651  -0.7723   0.0000
%!           0.0000   0.0000   0.0000   3.7417   0.8520  -0.2924   0.4342
%!           0.0000   0.0000   0.0000   0.0000  -1.5540   0.5334   0.5742
%!           0.0000   0.0000   0.0000   0.0000  -0.6533   0.2242   0.2414
%!           0.0000   0.0000   0.0000   0.0000  -0.5892   0.2022   0.2177 ];
%!
%! ec_e = [ -1.8325   1.0000   2.3752   0.0000  -0.8214   0.2819   1.8016
%!           0.4887   0.0000   0.3770  -0.5345   0.1874   0.5461   0.0000
%!          -0.1728   0.0000  -0.1333  -1.1339   0.1325   0.3861   0.0000
%!           0.0000   0.0000   0.0000   0.0000   0.8520  -0.2924   0.4342
%!           0.0000   0.0000   0.0000   0.0000  -1.0260  -0.1496   0.0000
%!           0.0000   0.0000   0.0000   0.0000   0.0000   1.1937   0.0000
%!           0.0000   0.0000   0.0000   0.0000   0.0000   0.0000   1.0000 ];
%!
%! bc_e = [  1.0000   2.0000   3.0000
%!           2.0000   1.0000   0.0000
%!           0.0000   0.0000   0.0000
%!           0.0000   0.0000   0.0000
%!           0.0000   0.0000   0.0000
%!           0.0000   0.0000   0.0000
%!           0.0000   0.0000   0.0000 ];
%!
%! cc_e = [  0.0000   1.0000   0.0000   0.0000  -1.2627   0.4334   0.4666
%!           0.3665   0.0000  -0.9803  -1.6036   0.1874   0.5461   0.0000 ];
%!
%! q_e = [   0.0000   1.0000   0.0000   0.0000   0.0000   0.0000   0.0000
%!           0.0000   0.0000   0.7071   0.0000   0.2740  -0.6519   0.0000
%!           0.0000   0.0000   0.0000   0.0000   0.8304   0.3491  -0.4342
%!           0.0000   0.0000   0.0000  -1.0000   0.0000   0.0000   0.0000
%!           0.0000   0.0000   0.0000   0.0000   0.4003   0.1683   0.9008
%!           0.0000   0.0000   0.7071   0.0000  -0.2740   0.6519   0.0000
%!           1.0000   0.0000   0.0000   0.0000   0.0000   0.0000   0.0000 ];
%!
%! z_e = [   0.0000   1.0000   0.0000   0.0000   0.0000   0.0000   0.0000
%!          -0.6108   0.0000   0.7917   0.0000   0.0000   0.0000   0.0000
%!           0.4887   0.0000   0.3770  -0.5345   0.1874   0.5461   0.0000
%!           0.0000   0.0000   0.0000   0.0000  -0.4107   0.1410   0.9008
%!           0.6108   0.0000   0.4713   0.2673  -0.1874  -0.5461   0.0000
%!          -0.1222   0.0000  -0.0943  -0.8018  -0.1874  -0.5461   0.0000
%!           0.0000   0.0000   0.0000   0.0000  -0.8520   0.2924  -0.4342 ];
%!
%!assert (ac, ac_e, 1e-4);
%!assert (ec, ec_e, 1e-4);
%!assert (bc, bc_e, 1e-4);
%!assert (cc, cc_e, 1e-4);
%!assert (q, q_e, 1e-4);
%!assert (z, z_e, 1e-4);
%!assert (ncont, ncont_e);


## observability staircase form of descriptor state-space models (SLICOT TG01ID)
%!shared ao, eo, bo, co, q, z, nobsv, ao_e, eo_e, bo_e, co_e, q_e, z_e, nobsv_e
%!
%! a = [ 2     0     0     0     0     0     0
%!       0     1     0     0     0     1     0
%!       2     0     0     2     0     0     0
%!       0     0     1     0     1     0     1
%!      -1     1     0    -1     0     1     0
%!       3     0     0     3     0     0     0
%!       1     0     1     1     1     0     1 ];
%!
%! e = [ 0     0     0     0     0     0     1
%!       0     0     0     0     0     0     3
%!       1     0     0     0     0     1     0
%!       0     0     0     0     1     0     2
%!       0     0     0     0     0    -1     0
%!       0     1     0     0     0     0     0
%!       0     0     1     1     0     0     0 ];
%!
%! b = [ 1     0
%!       0    -1
%!       0     1
%!       1     0
%!       0    -1
%!       0     1
%!       1     0 ];
%!
%! c = [ 2     0     0     0     0     0     1
%!       1     0     0     0     0     0     2
%!       0     0     0     0     0     0     3 ];
%!
%! tol = 0;
%!
%! [ao, eo, bo, co, q, z, nobsv] = sltg01id (a, e, b, c, tol);
%!
%! nobsv_e = 3;
%!
%! ao_e = [  0.2177   0.2414   0.5742   0.4342   0.0000  -0.4342   0.4666
%!           0.2022   0.2242   0.5334  -0.2924  -0.7723   0.2924   0.4334
%!          -0.5892  -0.6533  -1.5540   0.8520  -0.2651  -0.8520  -1.2627
%!           0.0000   0.0000   0.0000   3.7417   0.3780  -3.7417   0.0000
%!           0.0000   0.0000   0.0000   0.0000   1.7862   0.0000   0.0000
%!           0.0000   0.0000   0.0000   0.0000   0.0000   2.0000   0.0000
%!           0.0000   0.0000   0.0000   0.0000   0.0000   0.0000   0.0000 ];
%!
%! eo_e = [  1.0000   0.0000   0.0000   0.4342   0.0000   0.0000   1.8016
%!           0.0000   1.1937  -0.1496  -0.2924   0.3861   0.5461   0.2819
%!           0.0000   0.0000  -1.0260   0.8520   0.1325   0.1874  -0.8214
%!           0.0000   0.0000   0.0000   0.0000  -1.1339  -0.5345   0.0000
%!           0.0000   0.0000   0.0000   0.0000  -0.1333   0.3770   2.3752
%!           0.0000   0.0000   0.0000   0.0000   0.0000   0.0000   1.0000
%!           0.0000   0.0000   0.0000   0.0000  -0.1728   0.4887  -1.8325 ];
%!
%! bo_e = [  0.4666   0.0000
%!           0.4334   0.5461
%!          -1.2627   0.1874
%!           0.0000  -1.6036
%!           0.0000  -0.9803
%!           1.0000   0.0000
%!           0.0000   0.3665 ];
%!
%! co_e = [  0.0000   0.0000   0.0000   0.0000   0.0000   2.0000   1.0000
%!           0.0000   0.0000   0.0000   0.0000   0.0000   1.0000   2.0000
%!           0.0000   0.0000   0.0000   0.0000   0.0000   0.0000   3.0000 ];
%!
%! q_e = [   0.0000   0.0000   0.0000   0.0000   0.0000   1.0000   0.0000
%!           0.0000   0.0000   0.0000   0.0000   0.7917   0.0000  -0.6108
%!           0.0000   0.5461   0.1874  -0.5345   0.3770   0.0000   0.4887
%!           0.9008   0.1410  -0.4107   0.0000   0.0000   0.0000   0.0000
%!           0.0000  -0.5461  -0.1874   0.2673   0.4713   0.0000   0.6108
%!           0.0000  -0.5461  -0.1874  -0.8018  -0.0943   0.0000  -0.1222
%!          -0.4342   0.2924  -0.8520   0.0000   0.0000   0.0000   0.0000 ];
%!
%! z_e = [   0.0000   0.0000   0.0000   0.0000   0.0000   1.0000   0.0000
%!           0.0000  -0.6519   0.2740   0.0000   0.7071   0.0000   0.0000
%!          -0.4342   0.3491   0.8304   0.0000   0.0000   0.0000   0.0000
%!           0.0000   0.0000   0.0000  -1.0000   0.0000   0.0000   0.0000
%!           0.9008   0.1683   0.4003   0.0000   0.0000   0.0000   0.0000
%!           0.0000   0.6519  -0.2740   0.0000   0.7071   0.0000   0.0000
%!           0.0000   0.0000   0.0000   0.0000   0.0000   0.0000   1.0000 ];
%!
%!assert (ao, ao_e, 1e-4);
%!assert (eo, eo_e, 1e-4);
%!assert (bo, bo_e, 1e-4);
%!assert (co, co_e, 1e-4);
%!assert (q, q_e, 1e-4);
%!assert (z, z_e, 1e-4);
%!assert (nobsv, nobsv_e);


## Cascade inter-connection of two systems in state-space form
## Test from SLICOT AB05MD
## TODO: order of united state vector: consistency vs. compatibility?
#%!shared M, Me
#%! A1 = [ 1.0   0.0  -1.0
#%!        0.0  -1.0   1.0
#%!        1.0   1.0   2.0 ];
#%!
#%! B1 = [ 1.0   1.0   0.0
#%!        2.0   0.0   1.0 ].';
#%!
#%! C1 = [ 3.0  -2.0   1.0
#%!        0.0   1.0   0.0 ];
#%!
#%! D1 = [ 1.0   0.0
#%!        0.0   1.0 ];
#%!
#%! A2 = [-3.0   0.0   0.0
#%!        1.0   0.0   1.0
#%!        0.0  -1.0   2.0 ];
#%!
#%! B2 = [ 0.0  -1.0   0.0
#%!        1.0   0.0   2.0 ].';
#%!
#%! C2 = [ 1.0   1.0   0.0
#%!        1.0   1.0  -1.0 ];
#%!
#%! D2 = [ 1.0   1.0
#%!        0.0   1.0 ];
#%!
#%! sys1 = ss (A1, B1, C1, D1);
#%! sys2 = ss (A2, B2, C2, D2);
#%! sys = sys2 * sys1;
#%! [A, B, C, D] = ssdata (sys);
#%! M = [A, B; C, D];
#%!
#%! Ae = [ 1.0000   0.0000  -1.0000   0.0000   0.0000   0.0000
#%!        0.0000  -1.0000   1.0000   0.0000   0.0000   0.0000
#%!        1.0000   1.0000   2.0000   0.0000   0.0000   0.0000
#%!        0.0000   1.0000   0.0000  -3.0000   0.0000   0.0000
#%!       -3.0000   2.0000  -1.0000   1.0000   0.0000   1.0000
#%!        0.0000   2.0000   0.0000   0.0000  -1.0000   2.0000 ];
#%!
#%! Be = [ 1.0000   2.0000
#%!        1.0000   0.0000
#%!        0.0000   1.0000
#%!        0.0000   1.0000
#%!       -1.0000   0.0000
#%!        0.0000   2.0000 ];
#%!
#%! Ce = [ 3.0000  -1.0000   1.0000   1.0000   1.0000   0.0000
#%!        0.0000   1.0000   0.0000   1.0000   1.0000  -1.0000 ];
#%!
#%! De = [ 1.0000   1.0000
#%!        0.0000   1.0000 ];
#%!
#%! Me = [Ae, Be; Ce, De];
#%!
#%!assert (M, Me, 1e-4);


## Feedback inter-connection of two systems in state-space form
## Test from SLICOT AB05ND
%!shared M, Me
%! A1 = [ 1.0   0.0  -1.0
%!        0.0  -1.0   1.0
%!        1.0   1.0   2.0 ];
%!
%! B1 = [ 1.0   1.0   0.0
%!        2.0   0.0   1.0 ].';
%!
%! C1 = [ 3.0  -2.0   1.0
%!        0.0   1.0   0.0 ];
%!
%! D1 = [ 1.0   0.0
%!        0.0   1.0 ];
%!
%! A2 = [-3.0   0.0   0.0
%!        1.0   0.0   1.0
%!        0.0  -1.0   2.0 ];
%!
%! B2 = [ 0.0  -1.0   0.0
%!        1.0   0.0   2.0 ].';
%!
%! C2 = [ 1.0   1.0   0.0
%!        1.0   1.0  -1.0 ];
%!
%! D2 = [ 1.0   1.0
%!        0.0   1.0 ];
%!
%! sys1 = ss (A1, B1, C1, D1);
%! sys2 = ss (A2, B2, C2, D2);
%! sys = feedback (sys1, sys2);
%! [A, B, C, D] = ssdata (sys);
%! M = [A, B; C, D];
%!
%! Ae = [-0.5000  -0.2500  -1.5000  -1.2500  -1.2500   0.7500
%!       -1.5000  -0.2500   0.5000  -0.2500  -0.2500  -0.2500
%!        1.0000   0.5000   2.0000  -0.5000  -0.5000   0.5000
%!        0.0000   0.5000   0.0000  -3.5000  -0.5000   0.5000
%!       -1.5000   1.2500  -0.5000   1.2500   0.2500   1.2500
%!        0.0000   1.0000   0.0000  -1.0000  -2.0000   3.0000 ];
%!
%! Be = [ 0.5000   0.7500
%!        0.5000  -0.2500
%!        0.0000   0.5000
%!        0.0000   0.5000
%!       -0.5000   0.2500
%!        0.0000   1.0000 ];
%!
%! Ce = [ 1.5000  -1.2500   0.5000  -0.2500  -0.2500  -0.2500
%!        0.0000   0.5000   0.0000  -0.5000  -0.5000   0.5000 ];
%!
%! De = [ 0.5000  -0.2500
%!        0.0000   0.5000 ];
%!
%! Me = [Ae, Be; Ce, De];
%!
%!assert (M, Me, 1e-4);


## Rowwise concatenation of two systems in state-space form
## Test from SLICOT AB05OD
%!shared M, Me
%! A1 = [ 1.0   0.0  -1.0
%!        0.0  -1.0   1.0
%!        1.0   1.0   2.0 ];
%!
%! B1 = [ 1.0   1.0   0.0
%!        2.0   0.0   1.0 ].';
%!
%! C1 = [ 3.0  -2.0   1.0
%!        0.0   1.0   0.0 ];
%!
%! D1 = [ 1.0   0.0
%!        0.0   1.0 ];
%!
%! A2 = [-3.0   0.0   0.0
%!        1.0   0.0   1.0
%!        0.0  -1.0   2.0 ];
%!
%! B2 = [ 0.0  -1.0   0.0
%!        1.0   0.0   2.0 ].';
%!
%! C2 = [ 1.0   1.0   0.0
%!        1.0   1.0  -1.0 ];
%!
%! D2 = [ 1.0   1.0
%!        0.0   1.0 ];
%!
%! sys1 = ss (A1, B1, C1, D1);
%! sys2 = ss (A2, B2, C2, D2);
%! sys = [sys1, sys2];
%! [A, B, C, D] = ssdata (sys);
%! M = [A, B; C, D];
%!
%! Ae = [ 1.0000   0.0000  -1.0000   0.0000   0.0000   0.0000
%!        0.0000  -1.0000   1.0000   0.0000   0.0000   0.0000
%!        1.0000   1.0000   2.0000   0.0000   0.0000   0.0000
%!        0.0000   0.0000   0.0000  -3.0000   0.0000   0.0000
%!        0.0000   0.0000   0.0000   1.0000   0.0000   1.0000
%!        0.0000   0.0000   0.0000   0.0000  -1.0000   2.0000 ];
%!
%! Be = [ 1.0000   2.0000   0.0000   0.0000
%!        1.0000   0.0000   0.0000   0.0000
%!        0.0000   1.0000   0.0000   0.0000
%!        0.0000   0.0000   0.0000   1.0000
%!        0.0000   0.0000  -1.0000   0.0000
%!        0.0000   0.0000   0.0000   2.0000 ];
%!
%! Ce = [ 3.0000  -2.0000   1.0000   1.0000   1.0000   0.0000
%!        0.0000   1.0000   0.0000   1.0000   1.0000  -1.0000 ];
%!
%! De = [ 1.0000   0.0000   1.0000   1.0000
%!        0.0000   1.0000   0.0000   1.0000 ];
%!
%! Me = [Ae, Be; Ce, De];
%!
%!assert (M, Me, 1e-4);


## Parallel inter-connection of two systems in state-space form
## Test from SLICOT AB05PD
%!shared M, Me
%! A1 = [ 1.0   0.0  -1.0
%!        0.0  -1.0   1.0
%!        1.0   1.0   2.0 ];
%!
%! B1 = [ 1.0   1.0   0.0
%!        2.0   0.0   1.0 ].';
%!
%! C1 = [ 3.0  -2.0   1.0
%!        0.0   1.0   0.0 ];
%!
%! D1 = [ 1.0   0.0
%!        0.0   1.0 ];
%!
%! A2 = [-3.0   0.0   0.0
%!        1.0   0.0   1.0
%!        0.0  -1.0   2.0 ];
%!
%! B2 = [ 0.0  -1.0   0.0
%!        1.0   0.0   2.0 ].';
%!
%! C2 = [ 1.0   1.0   0.0
%!        1.0   1.0  -1.0 ];
%!
%! D2 = [ 1.0   1.0
%!        0.0   1.0 ];
%!
%! sys1 = ss (A1, B1, C1, D1);
%! sys2 = ss (A2, B2, C2, D2);
%! sys = sys1 + sys2;
%! [A, B, C, D] = ssdata (sys);
%! M = [A, B; C, D];
%!
%! Ae = [ 1.0000   0.0000  -1.0000   0.0000   0.0000   0.0000
%!        0.0000  -1.0000   1.0000   0.0000   0.0000   0.0000
%!        1.0000   1.0000   2.0000   0.0000   0.0000   0.0000
%!        0.0000   0.0000   0.0000  -3.0000   0.0000   0.0000
%!        0.0000   0.0000   0.0000   1.0000   0.0000   1.0000
%!        0.0000   0.0000   0.0000   0.0000  -1.0000   2.0000 ];
%!
%! Be = [ 1.0000   2.0000
%!        1.0000   0.0000
%!        0.0000   1.0000
%!        0.0000   1.0000
%!       -1.0000   0.0000
%!        0.0000   2.0000 ];
%!
%! Ce = [ 3.0000  -2.0000   1.0000   1.0000   1.0000   0.0000
%!        0.0000   1.0000   0.0000   1.0000   1.0000  -1.0000 ];
%!
%! De = [ 2.0000   1.0000
%!        0.0000   2.0000 ];
%!
%! Me = [Ae, Be; Ce, De];
%!
%!assert (M, Me, 1e-4);


## Gain of descriptor state-space models
%!shared p, pi, z, zi, k, ki, p_tf, pi_tf, z_tf, zi_tf, k_tf, ki_tf
%! P = ss (-2, 3, 4, 5);
%! Pi = inv (P);
%!
%! p = pole (P);
%! [z, k] = zero (P);
%!
%! pi = pole (Pi);
%! [zi, ki] = zero (Pi);
%!
%! P_tf = tf (P);
%! Pi_tf = tf (Pi);
%!
%! p_tf = pole (P_tf);
%! [z_tf, k_tf] = zero (P_tf);
%!
%! pi_tf = pole (Pi_tf);
%! [zi_tf, ki_tf] = zero (Pi_tf);
%!
%!assert (p, zi, 1e-4);
%!assert (z, pi, 1e-4);
%!assert (k, inv (ki), 1e-4);
%!assert (p_tf, zi_tf, 1e-4);
%!assert (z_tf, pi_tf, 1e-4);
%!assert (k_tf, inv (ki_tf), 1e-4);
