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
%% @deftypefn {Function File} { @var{a} =} areashape (@var{pp})
%%  Shape is defined with piecewise smooth polynomials. @var{pp} is a
%% cell where each elements is a 2-by-(poly_degree+1) array containing px(i,:) =
%% pp{i}(1,:) and py(i,:) = pp{i}(2,:).
%%
%% @end deftypefn

function A = shapearea (pp, tol=sqrt(eps)*[1 1])

  A = 0;

  integrand = @(t_, px_, py_) polyval (px_, t_) .* polyval ( polyderiv (py_), t_);
  d3_integral = @(px,py) py(1) * ( 20*px(4) + 15*px(3) + 12*px(2) + 10*px(1)) / 20 + ...
                       py(2) * ( 30*px(4) + 20*px(3) + 15*px(2) + 12*px(1)) / 30 + ...
                       py(3) * ( 12*px(4) + 6*px(3) + 4*px(2) + 3*px(1)) / 12;

  for is = 1:numel(pp)
    px = pp{is}(1,:);
    py = pp{is}(2,:);
    
    if length(px) > 4
    % degree> 3
      A += quad(@(t) integrand (t, px, py), 0, 1, tol);
    else
    % cubic polynomial
      px = padarray(px,[0 4-length(px)],0,'pre')
      py = padarray(py,[0 4-length(py)],0,'pre');
      A += d3_integral(px,py);
    end
    
  end

endfunction

%!demo % non-convex bezier shape
%! weirdhearth ={[-17.6816  -34.3989    7.8580    3.7971; ...
%!                15.4585  -28.3820  -18.7645    9.8519]; ...
%!                 [-27.7359   18.1039  -34.5718    3.7878; ...
%!                  -40.7440   49.7999  -25.5011    2.2304]};
%! A = shapearea (weirdhearth)

%!test
%! triangle = {[1 0; 0 0]; [-0.5 1; 1 0]; [-0.5 0.5; -1 1]};
%! A = shapearea (triangle);
%! assert (0.5, A);

%!test
%! circle = {[1.715729  -6.715729    0   5; ...
%!            -1.715729  -1.568542   8.284271    0]; ...
%!            [1.715729   1.568542  -8.284271    0; ...
%!             1.715729  -6.715729    0   5]; ...
%!            [-1.715729   6.715729    0  -5; ...
%!             1.715729   1.568542  -8.284271    0]; ...
%!            [-1.715729  -1.568542   8.284271    0; ...
%!            -1.715729   6.715729    0  -5]};
%! A = shapearea (circle);
%! assert (pi*5^2, A, 5e-2);

