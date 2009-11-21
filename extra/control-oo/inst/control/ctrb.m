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
## @deftypefn {Function File} {@var{co} =} ctrb (@var{sys})
## @deftypefnx {Function File} {@var{co} =} ctrb (@var{a}, @var{b})
## Controllability matrix.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2009
## Version: 0.1

function co = ctrb (a, b)

  if (nargin == 1)
    [a, b] = ssdata (a);
  elseif (nargin == 2)
    if (! isnumeric (a) || ! isnumeric (b) || rows(a) != rows (b) || ! issquare (a))
      error ("ctrb: invalid arguments");
    endif
  else
    print_usage ();
  endif

  [arows, acols] = size (a);
  [brows, bcols] = size (b);

  co = zeros (arows, acols*bcols);

  for k = 1 : arows
    co(:, ((k-1)*bcols + 1) : (k*bcols)) = b;
    b = a * b;
  endfor

endfunction


%!assert (ctrb ([1 0; 0 -0.5], [8; 8]), [8 8; 8 -4]);
