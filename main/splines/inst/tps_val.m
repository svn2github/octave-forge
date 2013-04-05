## Copyright (C) 2013 Nir Krakauer
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File}{[@var{yi}] =} tps_val(@var{x}, @var{coefs}, @var{xi})
##
## Evaluates a thin plate spline at given points @*
## @var{xi}
## 
## @var{coefs} should be the vector of fitted coefficients returned from @code{tpaps(x, y, [p])}
##
## @var{x} should be @var{n} by @var{d} in size, where @var{n} is the number of points and @var{d} the number of dimensions; @var{coefs} should be @var{n} + @var{d} + 1 by 1; @var{xi} should be @var{k} by @var{d}
##
## See the documentation to @code{tpaps} for more information
##
## @end deftypefn
## @seealso{tpaps}

## Author: Nir Krakauer <nkrakauer@ccny.cuny.edu>

function [yi]=tps_val(x,coefs,xi)


  [n d] = size(x); #d: number of dimensions; n: number of points [y should be n*1]
  k = size(xi, 1); #number of points for which to find the spline function value
  
  dist = @(x1, x2) norm(x2 - x1, 2, "rows"); #Euclidian distance between points in d-dimensional space

  #form of the Green's function for solutions
  G = @(r) merge(r == 0, 0, r .^ 2 .* log(r));
 
 a = coefs(1:n);
 b = coefs((n+1):end);

 
 yi = [ones(k, 1) xi] * b;
 
   warn_state = warning ("query", "Octave:broadcast").state;
   warning ("off", "Octave:broadcast"); #turn off warning message for automatic broadcasting when dist is called
   unwind_protect
  if k > n ##choose from either of two ways of computing the values of the thin plate spline at xi
    for i = 1:n
      yi = yi + a(i)*G(dist(x(i, :), xi));
    endfor
  else
    for i = 1:k
      yi(i) = yi(i) + dot(a, G(dist(x, xi(i, :))));
    endfor
  endif
   unwind_protect_cleanup
   warning (warn_state, "Octave:broadcast");
   end_unwind_protect
 


endfunction

%!shared x,y,c
%! x = ([1:10 10.5 11.3])'; y = sin(x);
%! c = tpaps(x,y,1);
%!assert (tpaps(x,y,1,x), tps_val(x,c,x));
%! x = rand(100, 2)*2 - 1; 
%! y = x(:, 1) .^ 2 + x(:, 2) .^ 2;
%! c = tpaps(x,y,1);
%!assert (tpaps(x,y,1,x), tps_val(x,c,x));
