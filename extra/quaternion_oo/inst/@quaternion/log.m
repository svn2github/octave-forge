## Copyright (C) 2011   Lukas F. Reichlin
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
## Logarithmus naturalis of a quaternion.  Used by octave for "log (q)".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.1

function q = log (q)

  if (nargin != 1)
    print_usage ();
  endif

  normq = abs (q);
  normv = sqrt (q.x.^2 + q.y.^2 + q.z.^2);
  acossq = acos (q.w ./ normq);

  q.w = log (normq);    
  q.x = (q.x ./ normv) .* acossq;
  q.y = (q.y ./ normv) .* acossq;
  q.z = (q.z ./ normv) .* acossq;
  
  ## FIXME: q = quaternion (2, 3, 4, 5)
  ##        p = log (exp (q))
  ##        p.v is wrong, probably somehow related to acos

endfunction
