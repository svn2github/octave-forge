## Copyright (C) 2010   Lukas F. Reichlin
## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## power operator of quaternions.  Used by Octave for "q.^x".
## Exponent x can be scalar or of appropriate size,
## but it must be real.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.2

function a = power (a, b)

  if (! isreal (b))
    error ("quaternion: power: exponent must be real");
  endif
  
  ## NOTE: if b is real, a is always a quaternion because
  ##       otherwise @quaternion/power is not called.
  ##       Therefore no test is necessary for a.

  if (b == -1)              # special case for ldivide and rdivide
    norm2 = norm2 (a);
    a.w = a.w ./ norm2;
    a.x = -a.x ./ norm2;
    a.y = -a.y ./ norm2;
    a.z = -a.z ./ norm2;
  else                      # general case
    na = abs (a);
    th = acos (a.w ./ na);
    nv = sqrt (a.x.^2 + a.y.^2 + a.z.^2);
    n.x = a.x ./ nv;
    n.y = a.y ./ nv;
    n.z = a.z ./ nv;

    nab = na.^b;
    a.w = nab .* cos (b.*th);

    snt = sin (b.*th);
    a.x = n.x .* nab .* snt;
    a.y = n.y .* nab .* snt;
    a.z = n.z .* nab .* snt;
  endif

endfunction
