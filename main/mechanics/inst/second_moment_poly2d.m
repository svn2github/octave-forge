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
%% @deftypefn {Function File} @var{J} = second_moment_shape2d (@var{p})
%% @deftypefnx{Function File} @var{J} = second_moment_shape2d (@var{p}),@var{type}, @var{matrix})
%% Calculates the second moment of area of a 2D shape. 
%%
%% The polygon is described in @var{p}, where each row is a different vertex as seen
%% from the center of mass of the shape (see @code{center_mass_shape2d}).
%%
%% The output @var{J} contains Ix, Ixy and Iy, in that order. It is assumed to be
%% oriented counter clockwise, otherwise multiply output by -1.
%%
%% If @var{matrix} is @code{true} then @var{J} is the symmetric second moment of area
%% matrix, instead of the vector @code{vech(J)}.
%% @var{type} indicates how is the shape described. So far the only case handled
%% is when @var{shape} is a 2D polygon, where each row of @var{shape} is a vertex.
%%
%% @seealso{inertia_moment_shape2d, center_mass_shape2d}
%% @end deftypefn

function J = second_moment_poly2d(shape, typep='polygon', matrix=false)

  if strcmpi (typep, 'polygon')

    [N dim] = size (shape);
    nxt = [2:N 1];
    px = shape(:,1);
    px_nxt = shape(nxt,1);
    py = shape(:,2);
    py_nxt = shape(nxt,2);
    
    cr_prod = px.*py_nxt - px_nxt.*py;

    J = zeros (3, 1);
    J(1) = sum ( (py.^2 + py.*py_nxt + py_nxt.^2) .* cr_prod); % Jx
    J(3) = sum ( (px.^2 + px.*px_nxt + px_nxt.^2) .* cr_prod); % Jy
    J(2) = 0.5 * sum ( (px.*py_nxt + 2*(px.*py + px_nxt.*py_nxt) + px_nxt.*py) .* cr_prod);
    J = J/12;

  elseif strcmpi (typep, 'polyline')

    error('second_moment_poly2d:Devel','Polyline, not implemented yet.');
    #TODO
  elseif strcmpi (typep, 'cbezier')

    error('second_moment_poly2d:Devel', 'Cubic bezier, not implemented yet');
    #TODO

  end

  if matrix
    J = vech2mat (J);
  end

end

