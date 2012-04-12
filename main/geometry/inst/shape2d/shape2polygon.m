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
%% @deftypefn {Function File} {@var{polygon} = } shape2polygon (@var{shape})
%% @deftypefnx {Function File} {@var{polygon} = } shape2polygon (@var{shape},@var{N})
%% Transforms a 2D shape described by piecewise smooth polynomials into a polygon.
%%
%% @var{shape} is a n-by-1 cell where each element is a pair of polynomials
%% compatible with polyval.
%% @var{polygon} is a k-by-2 matrix, where each row represents a vertex.
%% @var{N} defines the number of points to be used in non-straight edges.
%%
%% @seealso{polygon2shape, drawPolygon}
%% @end deftypefn

function polygon = shape2polygon (shape, N=16)

  polygon = cell2mat ( ...
             cellfun (@(x) func (x,N), shape,'UniformOutput',false) );

  %% TODO simply the polygon based on curvature
%  polygon = unique (polygon, 'rows');

  if size (polygon, 1) == 1
    polygon(2,1) = polyval (shape{1}(1,:), 1);
    polygon(2,2) = polyval (shape{1}(2,:), 1);
  end

endfunction

function y = func (x,N)

  if size (x,2) > 2
    t = linspace (0,1-1/N,N).';
    y(:,1) = polyval (x(1,:), t);
    y(:,2) = polyval (x(2,:), t);
  else
    y = x(:,2).';
  end

endfunction
