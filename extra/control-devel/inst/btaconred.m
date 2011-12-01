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
## @deftypefn{Function File} {[@var{Kr}, @var{info}] =} btaconred (@var{G}, @var{K}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} btaconred (@var{G}, @var{K}, @var{nr}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} btaconred (@var{G}, @var{K}, @var{opt}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} btaconred (@var{G}, @var{K}, @var{nr}, @var{opt}, @dots{})
##
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
## Uses SLICOT SB16AD by courtesy of
## @uref{http://www.slicot.org, NICONET e.V.}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2011
## Version: 0.1

function [Kr, info] = btaconred (varargin)

  [Kr, info] = __conred_sb16ad__ ("bta", varargin{:});

endfunction


%!shared Mo, Me
%! A =  [ -1.  0.   4.
%!         0.  2.   0.
%!         0.  0.  -3. ];
%!
%! B =  [  1.
%!         1.
%!         1. ];
%!
%! C =  [  1.  1.   1. ];
%!
%! D =  [  0. ];
%!
%! G = ss (A, B, C, D, "scaled", true);
%!
%! AC = [ -26.4000,    6.4023,    4.3868;
%!         32.0000,         0,         0;
%!               0,    8.0000,         0  ];
%!
%! BC = [      -16
%!               0
%!               0 ];
%!
%! CC = [   9.2994    1.1624    0.1090 ];
%!
%! DC = [        0 ];
%!
%! K = ss (AV, BV, CV, DV, "scaled", true);
%!
%! Kr = btaconred (G, K, 2, "weight", "ERROR", "tol1", 0.1, "tol2", 0.0);
%! [Ao, Bo, Co, Do] = ssdata (Kr);
%!
%! Ae = [   9.1900   0.0000
%!          0.0000 -34.5297 ];
%!
%! Be = [ -11.9593
%!         86.3137 ];
%!
%! Ce = [   2.8955  -1.3566 ];
%!
%! De = [   0.0000 ];
%!
%! Mo = [Ao, Bo; Co, Do];
%! Me = [Ae, Be; Ce, De];
%!
%!assert (Mo, Me, 1e-4);