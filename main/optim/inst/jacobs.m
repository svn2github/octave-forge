## Copyright (C) 2011 Fotios Kasolis <fotios.kasolis@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {Df =} jacobs (@var{f}, @var{x})
## @deftypefnx {Function File} {Df =} jacobs (@var{f}, @var{x}, @var{h})
## Calculate the jacobian of a function.
##
## Let @var{f} be a user-supplied function. Given a point @var{x} at which
## we seek for the Jacobian, the function @command{jacobs} returns the Jacobian
## matrix @code{d(f(1), @dots{}, df(n))/d(x(1), @dots{}, x(n))}. The
## function uses the complex step method and thus can be applied to real
## analytic functions. The optional argument @var{h} can be used to define
## the magnitude of the complex step and defaults to 1e-20.
##
## For example:
## 
## @example
## @group
## f = @@(x) [x(1)^2 + x(2); x(2)*exp(x(1))];
## Df = jacobs (f, [1,2])
## @end group
## @end example
## @end deftypefn

function Df = jacobs (f, x, h = 1e-20)

  if ( (nargin < 2) || (nargin > 3) )
    print_usage ();
  endif

  if (ischar (f))
    f = str2func (f, "global");
  endif

  if (! (isscalar (h)))
    error ("jacobs: H must be a scalar");
  endif

  if (abs (h) >= 1e-2)
    warning ("jacobs: H is too big and the result should not be trusted");
  endif

  n  = numel (x);
  Df = zeros (n, n);

  x = repmat (x(:), 1, n) + h * 1i * eye (n);

  for count = 1:n
    Df(:, count) = imag (f (x(:, count))(:));
  endfor

  Df /=  h;

endfunction

%!assert (jacobs (@(x) x, 1), 1)
%!assert (jacobs (@(x) x^2, 6), 12)
%!assert (jacobs (@(x) [x(1)^2; x(1)*x(2)], [1; 1]), [2, 0; 1, 1])
%!assert (jacobs (@(x) [x(1)^2 + x(2); x(2)*exp(x(1))], [1; 2]), [2, 1; 2*exp(1), exp(1)])

%% Test input validation
%!error jacobs ()
%!error jacobs (1)
%!error jacobs (1, 2, 3, 4)
%!error jacobs (@sin, 1, [1, 1])
%!error jacobs (@sin, 1, ones(2, 2))

%!demo
%! # Relative error against several h-values
%! k = 1:20; h = 10 .^ (-k); x = 0.3*pi;
%! err = zeros (1, numel (k));
%! for count = k
%!   err(count) = abs (jacobs (@sin, x, h(count)) - cos (x)) / abs (cos (x)) + eps;
%! endfor
%! loglog (h, err); grid minor;
%! xlabel ("h"); ylabel ("|Df(x) - cos(x)| / |cos(x)|")
%! title ("f(x)=sin(x), f'(x)=cos(x) at x = 0.3pi")
