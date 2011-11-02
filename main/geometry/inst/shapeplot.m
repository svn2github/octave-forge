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
%% @deftypefn {Function File} {@var{h} = } shapeplot (@var{shape})
%% @deftypefnx {Function File} {@var{h} = } shapeplot (@var{shape}, @var{N})
%% Pots a 2D shape defined by piecewise smooth polynomials.
%%
%% @end deftypefn

function h = shapeplot(shape, N = 16, varargin)

  p = shape2polygon(shape, N);
  h = drawPolygon(p,varargin{:});

endfunction
