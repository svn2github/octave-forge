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
%% @deftypefn {Function File} @var{cm} = center_mass_poly2d (@var{p})
%% Calculates the center of mass a 2D polygon.
%%
%% The polygon is described in @var{p}, where each row is a different vertex.
%% The algorithm was adapted from P. Bourke web page
%% @uref{http://local.wasp.uwa.edu.au/~pbourke/geometry/polyarea/}
%%
%% @seealso{inertia_moment_poly2d, area_poly2d}
%% @end deftypefn

function cm = center_mass_poly2d(poly)

  N = size(poly,1);
  nxt = [2:N 1];
  px = poly(:,1);
  px_nxt = poly(nxt,1);
  py = poly(:,2);
  py_nxt = poly(nxt,2);
  
  cm = zeros(1,2);
  cr_prod = (px.*py_nxt - px_nxt.*py);
  
  % Area
  A = sum(cr_prod)/2;

  % Center of mass  
  cm(1) = sum( (px+px_nxt) .* cr_prod );
  cm(2) = sum( (py+py_nxt) .* cr_prod );
  cm = cm/(6*A);
   
end

%!demo
%! % The center of mass of this two triangles is the same
%! % since both describe the same figure.
%!
%!  P = [0 0; 1 0; 0 1]; 
%!  P2=[0 0; 0.1 0; 0.2 0; 0.25 0; 1 0; 0 1];
%!  [center_mass_poly2d(P) center_mass_poly2d(P2)],
%!
%! % The centroid does not give the right answer
%! 
%!  [mean(P) mean(P2)],

