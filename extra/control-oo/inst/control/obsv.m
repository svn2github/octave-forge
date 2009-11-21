## Copyright (C) 2009   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{ob} =} obsv (@var{sys})
## @deftypefnx {Function File} {@var{ob} =} obsv (@var{a}, @var{c})
## Observability matrix.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2009
## Version: 0.1

function ob = obsv (a, c)

  if (nargin == 1)
    [a, b, c] = ssdata (a);
  elseif (nargin == 2)
    if (! isnumeric (a) || ! isnumeric (c) || columns(a) != columns (c) || ! issquare (a))
      error ("obsv: invalid arguments");
    endif
  else
    print_usage ();
  endif

  [arows, acols] = size (a);
  [crows, ccols] = size (c);

  ob = zeros (arows*crows, acols);

  for k = 1 : arows
    ob(((k-1)*crows + 1) : (k*crows), :) = c;
    c = c * a;
  endfor

endfunction


%!assert (obsv ([1 0; 0 -0.5], [8 8]), [8 8; 8 -4]);
