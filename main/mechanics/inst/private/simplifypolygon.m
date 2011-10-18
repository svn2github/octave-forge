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

function polygonsimp = simplifypolygon (polygon)

  # Filter colinear points
  edges = diff(polygon([1:end 1],:));
  ned = size(edges,1);
  nxt = [2:ned 1];
  
  # check if consecutive edges are parallel
  para = edges(:,1).*edges(nxt,2) - edges(:,2).*edges(nxt,1);
  ind = abs(para) > sqrt(eps);
  
  polygonsimp = polygon(circshift (ind,1),:);

endfunction
