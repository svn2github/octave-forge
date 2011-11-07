## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation, either version 3 of the License, or
##    any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{n} = } norm (@var{q})
## Computes the norm of a quaternion.
##
## The norm of a quaternion is defined as the sum of its squares components.
## @var{q} can be a N-by-4 array representign N quaternions. In that case
## @var{n} is of the same size as @var{q}.
##
## @end deftypefn

function n = norm (q)

  n = sqrt (sumsq (q,2));

endfunction
