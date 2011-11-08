## Copyright (C) 2011   Lukas F. Reichlin
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
## @deftypefn{Function File} {[@var{sysr}, @var{nr}] =} btamodred (@var{sys}, @dots{})
## Model order reduction by frequency weighted optimal Hankel-norm approximation method.
##
## @strong{Inputs}
## @table @var
## @item sys
## LTI model to be reduced.
## @item @dots{}
## Pairs of properties and values.
## TODO: describe options.
## @end table
##
## @strong{Outputs}
## @table @var
## @item sysr
## Reduced order state-space model.
## @item nr
## The order of the obtained system @var{sysr}.
## @end table
##
## @strong{Algorithm}@*
## Uses SLICOT AB09ID by courtesy of
## @uref{http://www.slicot.org, NICONET e.V.}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.1

function [sysr, nr] = btamodred (varargin)

  [sysr, nr] = __ab09id_modred__ ("bta", varargin{:});

endfunction


%!shared Mo, Me
%! A =  [ -26.4000,    6.4023,    4.3868;
%!         32.0000,         0,         0;
%!               0,    8.0000,         0 ];
%!
%! B =  [       16
%!               0
%!               0 ];
%!
%! C =  [   9.2994     1.1624     0.1090 ];
%!
%! D =  [        0 ];
%!
%! sys = ss (A, B, C, D);  % "scaled", false
%!
%! AV = [  0.2000   -1.0000
%!         1.0000         0 ];
%!
%! BV = [       1
%!              0 ];
%!
%! CV = [ -1.8000         0 ];
%!
%! DV = [       1 ];
%!
%! sysv = ss (AV, BV, CV, DV);
%!
%! sysr = btamodred (sys, "nr", 2, "left", sysv, "tol1", 0.1, "tol2", 0.0);
%! [Ao, Bo, Co, Do] = ssdata (sysr);
%!
%! Ae = [  9.1900   0.0000
%!         0.0000 -34.5297 ];
%!
%! Be = [ 11.9593
%!        16.9329 ];
%!
%! Ce = [  2.8955   6.9152 ];
%!
%! De = [  0.0000 ];
%!
%! Mo = [Ao, Bo; Co, Do];
%! Me = [Ae, Be; Ce, De];
%!
%!assert (Mo, Me, 1e-4);