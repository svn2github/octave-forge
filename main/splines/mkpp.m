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

## usage: pp = mkpp(x, P)
## Construct a piece-wise polynomial structure from sample points x and
## coefficients P.  The ith row of P, P(i,:), contains the coefficients 
## for the polynomial over the ith interval, ordered from highest to 
## lowest. There must be one row for each interval in x, so 
## rows(P) == length(x)-1.  
##
## You can concatenate multiple polynomials of the same order over the 
## same set of intervals using P = [ P1 ; P2 ; ... ; Pd ].  In this case,
## rows(P) == d*(length(x)-1).
##
## mkpp(x, P, d) is provided for compatibility, but if d is not specified
## it will be computed as round(rows(P)/(length(x)-1)) instead of defaulting
## to 1.

function pp = mkpp(x, P, d)
  if nargin < 2 || nargin > 3
    usage("pp = mkpp(x,P,d)");
  endif
  pp.x = x(:);
  pp.P = P;
  pp.n = length(x) - 1;
  pp.k = columns(P);
  if nargin < 3, d = round(rows(P)/pp.n); endif
  pp.d = d;
  if (pp.n*d != rows(P))
    error("mkpp: num intervals in x doesn't match num polynomials in P");
  endif
endfunction

%!demo # linear interpolation
%! x=linspace(0,pi,5)'; 
%! t=[sin(x),cos(x)];
%! m=diff(t)./(x(2)-x(1)); 
%! b=t(1:4,:);
%! pp = mkpp(x, [m(:),b(:)]);
%! xi=linspace(0,pi,50);
%! plot(x,t,"x;control;",xi,ppval(pp,xi),";interp;");