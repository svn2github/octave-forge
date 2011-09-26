%% Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%% 
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} @var{A} = area_poly2d (@var{p})
%% Calculates the Area of a 2D polygon.
%%
%% The polygon is described in @var{p}, where each row is a different vertex.
%% The algorithm was adapted from P. Bourke web page
%% @uref{http://local.wasp.uwa.edu.au/~pbourke/geometry/polyarea/}
%%
%% @seealso{inertia_moment_poly2d, center_mass_poly2d}
%% @end deftypefn

function A = area_poly2d(poly)

  N = size(poly,1);
  nxt = [2:N 1];
  px = poly(:,1);
  px_nxt = poly(nxt,1);
  py = poly(:,2);
  py_nxt = poly(nxt,2);

  A = sum(px.*py_nxt - px_nxt.*py)/2;
  
end

%!demo
%! % A parametrized arbitrary triagle and its area
%!
%!  triangle = @(a,b,h) [0 0; b 0; a h];
%!  h = linspace(0.1,1,10);
%!  b = pi;
%!  for i=1:length(h);
%!    P = triangle(0.1,b,h(i));
%!    area(i) = area_poly2d(P);
%!  end
%!
%! % The area of the triangle is b*h/2
%!  plot(h,area,'o',h,b*h/2); 
