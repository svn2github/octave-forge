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

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2009
## Version: 0.1

function [y_r, t_r, x_r] = initial (sys, x0, tfinal = [], dt = [])

  [y, t, x] = __timeresp__ (sys, "initial", ! nargout, tfinal, dt, x0);

  if (nargout)
    y_r = y;
    t_r = t;
    x_r = x;
  endif

endfunction


%!shared initial_c, initial_c_exp, initial_d, initial_d_exp
%!
%! A = [ -2.8    2.0   -1.8
%!       -2.4   -2.0    0.8
%!        1.1    1.7   -1.0 ];
%!
%! B = [ -0.8    0.5    0
%!        0      0.7    2.3
%!       -0.3   -0.1    0.5 ];
%!
%! C = [ -0.1    0     -0.3
%!        0.9    0.5    1.2
%!        0.1   -0.1    1.9 ];
%!
%! D = [ -0.5    0      0
%!        0.1    0      0.3
%!       -0.8    0      0   ];
%!
%! x_0 = [1, 2, 3];
%!
%! sysc = ss (A, B, C, D);
%!
%! [yc, tc, xc] = initial (sysc, x_0, 0.2, 0.1);
%! initial_c = round (1e4 * [yc, tc, xc]) / 1e4;
%!
%! sysd = c2d (sysc, 2);
%!
%! [yd, td, xd] = initial (sysd, x_0, 4);
%! initial_d = round (1e4 * [yd, td, xd]) / 1e4;
%!
%! ## expected values computed by the "dark side"
%!
%! yc_exp = [ -1.0000    5.5000    5.6000
%!            -0.9872    5.0898    5.7671
%!            -0.9536    4.6931    5.7598 ];
%!
%! tc_exp = [  0.0000
%!             0.1000
%!             0.2000 ];
%!
%! xc_exp = [  1.0000    2.0000    3.0000
%!             0.5937    1.6879    3.0929
%!             0.2390    1.5187    3.0988 ];
%!
%! initial_c_exp = [yc_exp, tc_exp, xc_exp];
%!
%! yd_exp = [ -1.0000    5.5000    5.6000
%!            -0.6550    3.1673    4.2228
%!            -0.5421    2.6186    3.4968 ];
%!
%! td_exp = [  0
%!             2
%!             4 ];
%!
%! xd_exp = [  1.0000    2.0000    3.0000
%!            -0.4247    1.5194    2.3249
%!            -0.3538    1.2540    1.9250 ];
%!
%! initial_d_exp = [yd_exp, td_exp, xd_exp];
%!
%!assert (initial_c, initial_c_exp)
%!assert (initial_d, initial_d_exp)
