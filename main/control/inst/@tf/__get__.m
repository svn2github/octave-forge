## Copyright (C) 2009 - 2010   Lukas F. Reichlin
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
## Access property values of TF objects.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2009
## Version: 0.2

function val = __get__ (sys, prop)

  switch (prop)  # {<internal name>, <user name>}
    case "num"
      val = cellfun ("@tfpoly/get", sys.num, "UniformOutput", false);
    case "den"
      val = cellfun ("@tfpoly/get", sys.den, "UniformOutput", false);
    case {"tfvar", "variable"}
      val = sys.tfvar;
    otherwise
      error ("get: invalid property name");
  endswitch

endfunction