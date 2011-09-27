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
%% @deftypefn {Function File} @var{I} = inertia_moment_poly2d (@var{p}, @var{m}, @var{offset})
%% Calculates the moment of inertia of a 2D star-shaped polygon.
%%
%% The polygon is described in @var{p}, where each row is a different vertex.
%% @var{m} is the total mass of the polygon, assumed uniformly distributed.
%% The optional argument @var{offset} is an origin translation vector. All vertex 
%% are transformed to the reference frame with origin at @var{offset}. 
%%
%% This expression assumes that the polygon is star-shaped. The position of the
%% vertices is assumed to be given from the center of mass of the polygon.
%% To change a general polygon to this description you can use:
%% @code{P = P - repmat(center_mass_poly2d(P),size(P,1))}.
%% or call the function using the offset:
%% @code{inertia_moment_poly2d (@var{p}, @var{m}, center_mass_poly2d(P))}
%%
%% @seealso{inertia_moment_ncpoly2d, center_mass_poly2d}
%% @end deftypefn

function I = inertia_moment_poly2d(poly,mass,offset=[0 0])
  numVerts = size(poly,1);
  R = repmat(offset,numVerts,1);
  
  V = poly - R;
  Vnext = poly([2:numVerts 1],:) - R;
  
  %% Area of the parallelograms
  A = sqrt(sumsq(cross([Vnext zeros(numVerts,1)],[V zeros(numVerts,1)],2),2));
  %% Distance between points
  B = dot(V,V,2) + dot(V,Vnext,2) + dot(Vnext,Vnext,2);
  
  C = sum(A.*B);
  
  I = mass*C/(6*sum(A));
end

%!demo
%! 
%! % The same triangle respect to one of its vertices described with two polygons
%!  P = [0 0; 1 0; 0 1]; 
%!  P2=[0 0; 0.1 0; 0.2 0; 0.25 0; 1 0; 0 1];
%!
%! % Now described from the center of mass of the triangle
%! Pc = P - repmat(center_mass_poly2d(P), 3, 1);
%! inertia_moment_poly2d(Pc,1)
%!
%! Pc = P2 -repmat(center_mass_poly2d(P2), size(P2,1), 1);
%! inertia_moment_poly2d(Pc,1)

