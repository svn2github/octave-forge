## Copyright (C) 2012   Lukas F. Reichlin
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
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## Display routine for iddata objects.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: February 2012
## Version: 0.1

function display (dat)

  datname = inputname (1);
  [outname, p] = __labels__ (dat.outname, "y");
  [inname, m] = __labels__ (dat.inname, "u");
  [exname, e] = __labels__ (dat.exname, "exp");
  
  [n, p, m, e] = size (dat);

  disp ("");
  disp (["Time domain data set '", datname, "' containing ", num2str(e), " experiments"]);


endfunction
