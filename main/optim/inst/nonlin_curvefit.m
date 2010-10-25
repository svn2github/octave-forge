## Copyright (C) 2010 Olaf Till <olaf.till@uni-jena.de>
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {[@var{p}, @var{fy}, @var{cvg},
## @var{outp}] =} nonlin_curvefit (@var{f}, @var{pin}, @var{x}, @var{y})
##
## @deftypefn {Function File} {[@var{p}, @var{fy}, @var{cvg},
## @var{outp}] =} nonlin_curvefit (@var{f}, @var{pin}, @var{x}, @var{y},
## @var{settings})
##
## Frontend for nonlinear fitting of values, computed by a model
## function, to observed values.
##
## Please refer to the description of @code{nonlin_residmin}. The only
## differences to @code{nonlin_residmin} are the additional arguments
## @var{x} (independent values, mostly, but not necessarily, an array of
## the same dimensions or the same number of rows as @var{y}) and
## @var{y} (array of observations), the returned value @var{fy} (final
## guess for observed values) instead of @var{resid}, that the model
## function has a second obligatory argument which will be set to
## @var{x} and is supposed to return guesses for the observations (with
## the same dimensions), and that the possibly user-supplied function for the
## jacobian of the model function has also a second obligatory argument
## which will be set to @var{x}.
##
## @seealso {nonlin_residmin}
##
## @end deftypefn

## PKG_ADD: __all_opts__ ("nonlin_curvefit");

function [p, fy, cvg, outp] = nonlin_curvefit (f, pin, x, y, settings)

  if (nargin == 1)
    p = __nonlin_residmin__ (f);
    return;
  endif

  if (nargin < 4 || nargin > 5)
    print_usage ();
  endif

  if (nargin == 4)
    settings = struct ();
  endif

  if (! isempty (dfdp = optimget (settings, "dfdp")))
    if (ischar (dfdp))
      dfdp = str2func (dfdp);
    endif
    settings = optimset \
	(settings, "dfdp", @ (p, varargin) dfdp (p, x, varargin{:}));
  endif

  [p, fy, cvg, outp] = __nonlin_residmin__ \
      (@ (p) f (p, x), pin, settings, struct ("observations", y));

endfunction
