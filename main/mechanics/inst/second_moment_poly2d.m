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
%% @deftypefn {Function File} @var{J} = second_moment_poly2d (@var{p})
%% Calculates the second moment of area of a 2D polygon.
%%
%% The polygon is described in @var{p}, where each row is a different vertex.
%% The output @var{J} contains Ix, Iy and Ixy, in that order.
%%
%% The algorithm was adapted from P. Bourke web page
%% @url{http://local.wasp.uwa.edu.au/~pbourke/geometry/polyarea/}
%%
%% @seealso{inertia_moment_poly2d, center_mass_poly2d}
%% @end deftypefn

function J = second_moment_poly2d(poly)

  N = size(poly,1);
  nxt = [2:N 1];
  px = poly(:,1);
  px_nxt = poly(nxt,1);
  py = poly(:,2);
  py_nxt = poly(nxt,2);
  
  cm = zeros(1,2);
  cr_prod = (px.*py_nxt - px_nxt.*py);

  J = zeros(1,3);
  J(1) = sum((py.^2 + py.*py_nxt + py_nxt.^2).*cr_prod);
  J(2) = sum((px.^2 + px.*px_nxt + py_nxt.^2).*cr_prod);
  J(3) = 0.5*sum((px.*py_nxt + 2*px.*py + px_nxt.*py_nxt + px_nxt.*py).*cr_prod);
  J = J/12;
  
end

