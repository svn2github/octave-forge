## Copyright (C) 1996, 2000, 2005, 2007
##               Auburn University.  All rights reserved.
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## [a,b,c,d] = unpacksys(sys)
## Obsolete.  Use sys2ss instead.

## Author: David Clem
## Created: August 19, 1994

function [a, b, c, d] = unpacksys (syst)

  warning ("unpacksys obsolete; calling sys2ss");
  [a, b, c, d] = sys2ss (syst);

endfunction

