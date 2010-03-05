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

## -*- texinfo -*-
## @deftypefn {Function File} {} swapcols (inputs)
## @format
##  function B = swapcols(A)
##  permute columns of A into reverse order
## @end format
## @end deftypefn

## Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Created: July 23, 1992
## Conversion to Octave R. Bruce Tenison July 4, 1994

function B = swapcols (A)

  m = length (A(1,:));
  idx = m:-1:1;
  B = A(:,idx);

endfunction

