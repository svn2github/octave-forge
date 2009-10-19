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
## @deftypefn {Function File} {@var{sys} =} lft (@var{sys1}, @var{sys2})
## @deftypefn {Function File} {@var{sys} =} lft (@var{sys1}, @var{sys2}, @var{nu}, @var{ny})
## Linear fractional tranformation, also known as redheffer star product.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2009
## Version: 0.1

function sys = lft (sys1, sys2, nu, ny)

  if (nargin != 2 && nargin != 4)
    print_usage ();
  endif

  ## object conversion done by sysgroup if necessary

  [p1, m1] = size (sys1);
  [p2, m2] = size (sys2);

  nu_max = min (p1, m2);
  ny_max = min (p2, m1);

  if (nargin == 2)  # sys = lft (sys1, sys2)
    nu = nu_max;
    ny = ny_max;
  else  # sys = lft (sys1, sys2, nu, ny)
    if (isnumeric (nu) && isscalar (nu))
      nu = round (abs (nu));
    else
      error ("lft: argument nu must be a positive integer");
    endif

    if (isnumeric (ny) && isscalar (ny))
      ny = round (abs (ny));
    else
      error ("lft: argument ny must be a positive integer");
    endif

    if (nu > nu_max)
      error ("lft: argumend nu (%d) must be smaller than %d", nu, nu_max+1);
    endif

    if (ny > ny_max)
      error ("lft: argument ny (%d) must be smaller than %d", ny, ny_max+1);
    endif
  end

  M11 = zeros (m1, p1);
  M12 = [zeros(m1-nu, p2); eye(nu), zeros(nu, p2-nu)];
  M21 = [zeros(ny, p1-ny), eye(ny); zeros(m2-ny, p1)];
  M22 = zeros (m2, p2);

  M = [M11, M12; M21, M22];

  in_idx = [1 : (m1-nu), m1 + (ny+1 : m2)];
  out_idx = [1 : (p1-ny), p1 + (nu+1 : p2)];

  sys = __sysgroup__ (sys1, sys2);
  sys = __sysconnect__ (sys, M);
  sys = __sysprune__ (sys, out_idx, in_idx);

  [p, m] = size (sys);

  if (m == 0)
    warning ("lft: resulting system has no inputs");
  endif

  if (p == 0)
    warning ("lft: resulting system has no outputs");
  endif

endfunction
