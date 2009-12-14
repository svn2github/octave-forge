## Copyright (C) 2009   Lukas F. Reichlin
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
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {[@var{K}, @var{N}, @var{gamma}] =} hinfsyn (@var{P}, @var{nmeas}, @var{ncon})
## @deftypefnx{Function File} {[@var{K}, @var{N}, @var{gamma}] =} hinfsyn (@var{P}, @var{nmeas}, @var{ncon}, @var{gamma})
## H-infinity control synthesis for LTI plant.
## Uses SLICOT SB10FD and SB10DD by courtesy of NICONET e.V.
## <http://www.slicot.org>
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2009
## Version: 0.1

function [K, varargout] = hinfsyn (P, nmeas, ncon, gmax = 1e6)

  ## check input arguments
  if (nargin < 3 || nargin > 4)
    print_usage ();
  endif
  
  if (! isa (P, "lti"))
    error ("hinfsyn: first argument must be a LTI system");
  endif
  
  if (! isscalar (nmeas) || ! isnumeric (nmeas) || isempty (nmeas))
    error ("hinfsyn: second argument invalid");
  endif
  
  if (! isscalar (ncon) || ! isnumeric (ncon) || isempty (ncon))
    error ("hinfsyn: third argument invalid");
  endif
  
  if (! isscalar (gmax) || ! isnumeric (gmax) || isempty (gmax) || gmax < 0)
    error ("hinfsyn: fourth argument invalid");
  endif

  [a, b, c, d, tsam] = ssdata (P);
  
  ## check assumption A1
  m = columns (b);
  p = rows (c);
  
  m1 = m - ncon;
  p1 = p - nmeas;
  
  if (! isstabilizable (P(:, m1+1 : m)))
    error ("hinfsyn: (A, B2) must be stabilizable");
  endif
  
  if (! isdetectable (P(p1+1 : p, :)))
    error ("hinfsyn: (A, C2) must be detectable");
  endif

  ## H-infinity synthesis
  if (tsam > 0)  # discrete plant
    [ak, bk, ck, dk] = slsb10dd (a, b, c, d, ncon, nmeas, gmax);
  else  # continuous plant
    [ak, bk, ck, dk] = slsb10fd (a, b, c, d, ncon, nmeas, gmax);
  endif
  
  ## controller
  K = ss (ak, bk, ck, dk, tsam);
  
  if (nargout > 1)
    N = lft (P, K);
    varargout{1} = N;
    if (nargout > 2)
      varargout{2} = norm (N, inf);
    endif
  endif

endfunction


## continuous-time case
%!shared M, M_exp
%! A = [-1.0  0.0  4.0  5.0 -3.0 -2.0
%!      -2.0  4.0 -7.0 -2.0  0.0  3.0
%!      -6.0  9.0 -5.0  0.0  2.0 -1.0
%!      -8.0  4.0  7.0 -1.0 -3.0  0.0
%!       2.0  5.0  8.0 -9.0  1.0 -4.0
%!       3.0 -5.0  8.0  0.0  2.0 -6.0];
%!
%! B = [-3.0 -4.0 -2.0  1.0  0.0
%!       2.0  0.0  1.0 -5.0  2.0
%!      -5.0 -7.0  0.0  7.0 -2.0
%!       4.0 -6.0  1.0  1.0 -2.0
%!      -3.0  9.0 -8.0  0.0  5.0
%!       1.0 -2.0  3.0 -6.0 -2.0];
%!
%! C = [ 1.0 -1.0  2.0 -4.0  0.0 -3.0
%!      -3.0  0.0  5.0 -1.0  1.0  1.0
%!      -7.0  5.0  0.0 -8.0  2.0 -2.0
%!       9.0 -3.0  4.0  0.0  3.0  7.0
%!       0.0  1.0 -2.0  1.0 -6.0 -2.0];
%!
%! D = [ 1.0 -2.0 -3.0  0.0  0.0
%!       0.0  4.0  0.0  1.0  0.0
%!       5.0 -3.0 -4.0  0.0  1.0
%!       0.0  1.0  0.0  1.0 -3.0
%!       0.0  0.0  1.0  7.0  1.0];
%!
%! P = ss (A, B, C, D);
%! K = hinfsyn (P, 2, 2, 15);
%! M = [K.A, K.B; K.C, K.D];
%!
%! KA = [ -2.8043  14.7367   4.6658   8.1596   0.0848   2.5290
%!         4.6609   3.2756  -3.5754  -2.8941   0.2393   8.2920
%!       -15.3127  23.5592  -7.1229   2.7599   5.9775  -2.0285
%!       -22.0691  16.4758  12.5523 -16.3602   4.4300  -3.3168
%!        30.6789  -3.9026  -1.3868  26.2357  -8.8267  10.4860
%!        -5.7429   0.0577  10.8216 -11.2275   1.5074 -10.7244];
%!
%! KB = [ -0.1581  -0.0793
%!        -0.9237  -0.5718
%!         0.7984   0.6627
%!         0.1145   0.1496
%!        -0.6743  -0.2376
%!         0.0196  -0.7598];
%!
%! KC = [ -0.2480  -0.1713  -0.0880   0.1534   0.5016  -0.0730
%!         2.8810  -0.3658   1.3007   0.3945   1.2244   2.5690];
%!
%! KD = [  0.0554   0.1334
%!        -0.3195   0.0333];
%!
%! M_exp = [KA, KB; KC, KD];
%!
%!assert (M, M_exp, 1e-4);


## discrete-time case
%!shared M, M_exp
%! A = [-0.7  0.0  0.3  0.0 -0.5 -0.1
%!      -0.6  0.2 -0.4 -0.3  0.0  0.0
%!      -0.5  0.7 -0.1  0.0  0.0 -0.8
%!      -0.7  0.0  0.0 -0.5 -1.0  0.0
%!       0.0  0.3  0.6 -0.9  0.1 -0.4
%!       0.5 -0.8  0.0  0.0  0.2 -0.9];
%!
%! B = [-1.0 -2.0 -2.0  1.0  0.0
%!       1.0  0.0  1.0 -2.0  1.0
%!      -3.0 -4.0  0.0  2.0 -2.0
%!       1.0 -2.0  1.0  0.0 -1.0
%!       0.0  1.0 -2.0  0.0  3.0
%!       1.0  0.0  3.0 -1.0 -2.0];
%!
%! C = [ 1.0 -1.0  2.0 -2.0  0.0 -3.0
%!      -3.0  0.0  1.0 -1.0  1.0  0.0
%!       0.0  2.0  0.0 -4.0  0.0 -2.0
%!       1.0 -3.0  0.0  0.0  3.0  1.0
%!       0.0  1.0 -2.0  1.0  0.0 -2.0];
%!
%! D = [ 1.0 -1.0 -2.0  0.0  0.0
%!       0.0  1.0  0.0  1.0  0.0
%!       2.0 -1.0 -3.0  0.0  1.0
%!       0.0  1.0  0.0  1.0 -1.0
%!       0.0  0.0  1.0  2.0  1.0];
%!
%! P = ss (A, B, C, D, 1);  # value of sampling time doesn't matter
%! K = hinfsyn (P, 2, 2, 111.294);
%! M = [K.A, K.B; K.C, K.D];
%!
%! KA = [-18.0030  52.0376  26.0831  -0.4271 -40.9022  18.0857
%!        18.8203 -57.6244 -29.0938   0.5870  45.3309 -19.8644
%!       -26.5994  77.9693  39.0368  -1.4020 -60.1129  26.6910
%!       -21.4163  62.1719  30.7507  -0.9201 -48.6221  21.8351
%!        -0.8911   4.2787   2.3286  -0.2424  -3.0376   1.2169
%!        -5.3286  16.1955   8.4824  -0.2489 -12.2348   5.1590];
%!
%! KB = [ 16.9788  14.1648
%!       -18.9215 -15.6726
%!        25.2046  21.2848
%!        20.1122  16.8322
%!         1.4104   1.2040
%!         5.3181   4.5149];
%!
%! KC = [ -9.1941  27.5165  13.7364  -0.3639 -21.5983   9.6025
%!         3.6490 -10.6194  -5.2772   0.2432   8.1108  -3.6293];
%!
%! KD = [  9.0317   7.5348
%!        -3.4006  -2.8219];
%!
%! M_exp = [KA, KB; KC, KD];
%!
%!assert (M, M_exp, 1e-4);