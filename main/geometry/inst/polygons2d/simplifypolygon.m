## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{spoly} = } simplifypolygon (@var{poly})
%% Filter colinear vertex from a 2D polygon.
%%
%% @var{poly} is a N-by-2 matrix, each row representing a vertex.
%%
%% @seealso{shape2polygon}
%% @end deftypefn

function polygonsimp = simplifypolygon (polygon)

  # Filter colinear points
  edges = diff(polygon([1:end 1],:));
  ned = size(edges,1);
  nxt = [2:ned 1];

  # check if consecutive edges are parallel
  para = edges(:,1).*edges(nxt,2) - edges(:,2).*edges(nxt,1);
  ind = abs(para) > sqrt(eps);

  polygonsimp = polygon(circshift (ind,1),:);

  if isempty(polygonsimp)
    warning('simplifypolygon:devel',"The simplification gives an empty polygon. Returning original\n");
    polygonsimp = polygon;
  end

endfunction

%!test
%!  P = [0 0; 1 0; 0 1];
%!  P2 = [0 0; 0.1 0; 0.2 0; 0.25 0; 1 0; 0 1; 0 0.7; 0 0.6; 0 0.3; 0 0.1];
%! assert(P,simplifypolygon (P2))

%!demo
%!
%!  P = [0 0; 1 0; 0 1];
%!  P2 = [0 0; 0.1 0; 0.2 0; 0.25 0; 1 0; 0 1; 0 0.7; 0 0.6; 0 0.3; 0 0.1];
%!  Pr = simplifypolygon (P2);
%!
%!  cla
%!  drawPolygon(P,'or;Reference;');
%!  hold on
%!  drawPolygon(P2,'x-b;Redundant;');
%!  drawPolygon(Pr,'*g;Simplified;');
%!  hold off
%!
%! % --------------------------------------------------------------------------
%! % The two polygons describe the same figure, a triangle. Extra points are
%! % removed form the redundant one.
