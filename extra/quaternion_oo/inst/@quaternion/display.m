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
## Display routine for quaternions. Used by Octave internally.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1


function display (q)

  disp ([inputname(1), ".w ="]);
  disp (q.w);
  disp ("");
  disp ([inputname(1), ".x ="]);
  disp (q.x);
  disp ("");
  disp ([inputname(1), ".y ="]);
  disp (q.y);
  disp ("");
  disp ([inputname(1), ".z ="]);
  disp (q.z);
  disp ("");

endfunction