## Copyright (C) 2000 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## usage: [x, P, n, k, d] = unmkpp(pp)
## Extract the components of a pp structure.  They are as follows:
##   x: sample points
##   P: polynomial coefficients for points in sample interval
##      P(i,:) contains the coefficients for the polynomial over interval i
##      ordered from highest to lowest.  If d > 1, P(r,i,:) contains the
##      coeffients for the r-th polynomial defined on interval i.  However
##      octave does not support 3-dimensional matrices, so define:
##      	c = reshape (P(:, j), n, d);
##	Now c(i,r) is j-th coefficient of the r-th polynomial over the
##      i-th interval.
##   n: number of polynomial pieces
##   k: order of the polynomial + 1
##   d: number of polynomials defined for each interval
function [x, P, n, k, d] = unmkpp(pp)
  if nargin == 0
    usage("[x, P, n, k, d] = unmkpp(pp)")
  endif
  if !isstruct(pp)
    error("unmkpp: expecting piecewise polynomial structure");
  endif
  x = pp.x;
  P = pp.P;
  n = pp.n;
  k = pp.k;
  d = pp.d;
endfunction
