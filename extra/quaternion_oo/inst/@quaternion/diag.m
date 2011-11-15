## Copyright (C) 2010   Lukas F. Reichlin
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
## @deftypefn {Function File} {@var{q} =} diag (@var{v})
## @deftypefnx {Function File} {@var{q} =} diag (@var{v}, @var{k})
## Return a diagonal quaternion matrix with quaternion vector V on diagonal K.
## The second argument is optional. If it is positive,
## the vector is placed on the K-th super-diagonal.
## If it is negative, it is placed on the -K-th sub-diagonal.
## The default value of K is 0, and the vector is placed
## on the main diagonal.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1

function a = diag (a, b = 0)

  if (nargin == 0 || nargin > 2)
    print_usage ();
  endif

  a.w = diag (a.w, b);
  a.x = diag (a.x, b);
  a.y = diag (a.y, b);
  a.z = diag (a.z, b);

endfunction
