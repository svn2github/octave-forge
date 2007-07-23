## Copyright (C) 2005 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} @var{Pr} = min_max (@var{Pp})
## @code{min_max} returns variable Pr with range of matrix rows
##
## @example
## PR - R x 2 matrix of min and max values for R input elements
## @end example
##
## @example
## Pp = [1 2 3; -1 -0.5 -3]
## pr = min_max(Pp);
## pr = [1 3; -0.5 -3];
## @end example
## @end deftypefn

## Author: Michel D. Schmid

function Pr = min_max(Pp)

  ## check number of input args
  error(nargchk(1,1,nargin))

  Pr = []; # returns an empty matrix
  if ismatrix(Pp)
    if isreal(Pp) # be sure, this is no complex matrix
      Pr = [min(Pp,[],2) max(Pp,[],2)];
    else
      error("Argument has illegal type.")
    endif
  else
    error("Argument must be a matrix.")
  endif

endfunction

%!test fail("min_max(1)","Argument must be a matrix.")
%!test fail("min_max("testString")","Argument must be a matrix")


