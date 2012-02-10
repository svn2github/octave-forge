%% Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; if not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} { @var{cm} =} shapecentroid (@var{pp})
%%  Centroid of a plane shape defined with piecewise smooth polynomials.
%%
%% The shape is defined with piecewise smooth polynomials. @var{pp} is a
%% cell where each elements is a 2-by-(poly_degree+1) matrix containing a pair
%% of polynomials.
%% @code{px(i,:) = pp@{i@}(1,:)} and @code{py(i,:) = pp@{i@}(2,:)}.
%%
%% @seealso{shapearea, shape2polygon}
%% @end deftypefn

function cm = shapecentroid (shape)

  cm = sum( cell2mat ( cellfun (@CMint, shape, 'UniformOutput', false)));
  A = shapearea(shape);
  cm = cm / A;

endfunction

function dcm = CMint (x)

    px = x(1,:);
    py = x(2,:);
    Px = polyint (conv(conv (px , px)/2 , polyderiv (py)));
    Py = polyint (conv(-conv (py , py)/2 , polyderiv (px)));

    dcm = zeros (1,2);
    dcm(1) = diff(polyval(Px,[0 1]));
    dcm(2) = diff(polyval(Py,[0 1]));

endfunction

%!demo % non-convex bezier shape
%! weirdhearth ={[-17.6816  -34.3989    7.8580    3.7971; ...
%!                15.4585  -28.3820  -18.7645    9.8519]; ...
%!                 [-27.7359   18.1039  -34.5718    3.7878; ...
%!                  -40.7440   49.7999  -25.5011    2.2304]};
%! CoM = shapecentroid (weirdhearth)

%!test
%! square = {[1 -0.5; 0 -0.5]; [0 0.5; 1 -0.5]; [-1 0.5; 0 0.5]; [0 -0.5; -1 0.5]};
%! CoM = shapecentroid (square);
%! assert (CoM, [0 0], sqrt(eps));
%! square_t = shapetransform (square,[1;1]);
%! CoM_t = shapecentroid (square_t);
%! assert (CoM, [0 0], sqrt(eps));
%! assert (CoM_t, [1 1], sqrt(eps));

%!test
%! circle = {[1.715729  -6.715729    0   5; ...
%!            -1.715729  -1.568542   8.284271    0]; ...
%!            [1.715729   1.568542  -8.284271    0; ...
%!             1.715729  -6.715729    0   5]; ...
%!            [-1.715729   6.715729    0  -5; ...
%!             1.715729   1.568542  -8.284271    0]; ...
%!            [-1.715729  -1.568542   8.284271    0; ...
%!            -1.715729   6.715729    0  -5]};
%! CoM = shapecentroid (circle);
%! assert (CoM , [0 0], 5e-3);

%!test
