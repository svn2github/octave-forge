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
%% @deftypefn {Function File} @var{I} = inertia_moment_ncpoly2d (@var{p}, @var{m})
%% Calculates the moment of inertia of a simple 2D polygon.
%%
%% The polygon is described in @var{p}, where each row is a different vertex.
%% @var{m} is the total mass of the polygon, assumed uniformly distributed.
%% The polygon is triangulated using delaunay algorithm and then the 
%% Superposition Principle and the Parallel axis theorem are applied to each
%% triangle.
%%
%% The position of the vertices is assumed to be given from the center of mass 
%% of the polygon.
%% To change a general polygon to this description you can use:
%% @code{P = P - repmat(center_mass_poly2d(P),size(P,1))}.
%%
%% @seealso{inertia_moment_poly2d, center_mass_poly2d}
%% @end deftypefn

function I = inertia_moment_ncpoly2d (poly, M)
  %% Get total area
  A = area_poly2d (poly);

  %% triangulate
  T = delaunay (poly(:,1), poly(:,2));
  nT = size(T,1);
  
% debug
% triplot(T,poly(:,1),poly(:,2),'color',[0.8 0.8 0.8])
% hold on
% drawPolygon(poly,'k'); 
% hold off;

  I = 0;
  for it = 1:nT
    P = poly (T(it,:), :);
    %% get centers of mass
    cm =  center_mass_poly2d (P);
    
    % Check if triangle CoM is inside polygon
    if ~inpolygon (cm(1), cm(2), poly(:,1), poly(:,2))
      continue
    end
    
    %% get the mass as fraction of total area
    a = area_poly2d (P);
    if a < 0
      aux = P(1,:);
      P(1,:) = P(2,:);
      P(2,:) = aux;
      a = -a;
    end
    m = M*a/A;

% debug
% patch(P(:,1),P(:,2),'facecolor','b','edgecolor','none');
% pause



    %% get moment of inertia
    mo = inertia_moment_poly2d (P, m, cm);

    %% Assemble: Superposition + parallel axis
    I += mo + m * sumsq (cm);
  end

end

%!demo
%! % C shape polygon
%!  poly = [0 0; 1 0; 1 0.25; 0.25 0.25; 0.25 0.75; 1 0.75; 1 1; 0 1];
%! 
%! % Take to center of mass
%!  poly = poly - repmat(center_mass_poly2d(poly),size(poly,1),1);
%!  A = area_poly2d(poly);
%!
%!  I = inertia_moment_ncpoly2d(poly,1)
%!
%!  % It should give (breaking C in rectangles)
%!  r1 = [poly(1:3,:); poly(1,1) poly(3,2)]; a1 = area_poly2d(r1); m1 = abs(a1/A); 
%!  c1 = center_mass_poly2d(r1); I1 = inertia_moment_poly2d(r1,m1,c1);
%!  r2 = [r1(4,:); poly(4:5,:); poly(1,1) poly(5,2)]; a2 = area_poly2d(r2); m2 = abs(a2/A); 
%!  c2 = center_mass_poly2d(r2); I2 = inertia_moment_poly2d(r2,m2,c2);
%!  r3 = [poly(5:8,:); r2(4,:)]; a3 = area_poly2d(r3); m3 = abs(a3/A); 
%!  c3 = center_mass_poly2d(r3); I3 = inertia_moment_poly2d(r3,m3,c3);
%! 
%! I1 + m1*sumsq(c1) + I2 + m2*sumsq(c2) + I3 + m3*sumsq(c3)

%!test
%! poly = [0 0; 1 0; 1 0.25; 0.25 0.25; 0.25 0.75; 1 0.75; 1 1; 0 1];
%! poly = poly - repmat(center_mass_poly2d(poly),size(poly,1),1);
%! A = area_poly2d(poly);
%! I = inertia_moment_ncpoly2d(poly,1)
%! % It should give (breaking C in rectangles)
%! r1 = [poly(1:3,:); poly(1,1) poly(3,2)]; a1 = area_poly2d(r1); m1 = abs(a1/A); 
%! c1 = center_mass_poly2d(r1); I1 = inertia_moment_poly2d(r1,m1,c1);
%! r2 = [r1(4,:); poly(4:5,:); poly(1,1) poly(5,2)]; a2 = area_poly2d(r2); m2 = abs(a2/A); 
%! c2 = center_mass_poly2d(r2); I2 = inertia_moment_poly2d(r2,m2,c2);
%! r3 = [poly(5:8,:); r2(4,:)]; a3 = area_poly2d(r3); m3 = abs(a3/A); 
%! c3 = center_mass_poly2d(r3); I3 = inertia_moment_poly2d(r3,m3,c3);
%! I_shouldbe = I1 + m1*sumsq(c1) + I2 + m2*sumsq(c2) + I3 + m3*sumsq(c3);
%! assert(I,I_shouldbe)

