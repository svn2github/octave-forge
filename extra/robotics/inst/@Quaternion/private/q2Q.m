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
## @deftypefn {Function File} {} q2Q (@var{obj})
## Convertas a quaterion in to a Quaternion.
##
## @end deftypefn

function Q = q2Q (Q,q)

  Q.s = q(0);
  Q.v(1) = q(1);
  Q.v(2) = q(2);
  Q.v(3) = q(3);
  
  ## TODO Rest of the fields

  warning("robotics:Devel","Conversion from quaternion to Quaterninon not finished.");

endfunction
