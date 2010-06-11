## Copyright (C) 2008, 2009, 2010 Luca Favatella <slackydeb@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
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
## @deftypefn{Function File} {} rastriginsfcn (@var{x})
## Rastrigin's function.
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 1.4

function retval = rastriginsfcn (x)
  if (nargout != 1)
    print_usage ();
  else
    x1 = x(:, 1);
    x2 = x(:, 2);
    retval = 20 + (x1 .** 2) + (x2 .** 2) - 10 .* (cos (2 .* pi .* x1) +
                                                   cos (2 .* pi .* x2));
  endif
endfunction


%!error rastriginsfcn ()
%!error rastriginsfcn ([0, 0], "other argument")

%!assert (rastriginsfcn ([0, 0]), 0)
%!assert (rastriginsfcn ([0, 0; 0, 0]), [0; 0])