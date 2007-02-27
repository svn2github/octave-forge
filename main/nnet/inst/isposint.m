## Copyright (C) 2005 Michel D. Schmid     <michaelschmid@users.sourceforge.net>
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
## @deftypefn {Function File} {} @var{f} = isposint(@var{n})
## @code{isposint} True for positive integer values.
##
## 
## @end deftypefn

## Author: Michel D. Schmid <michaelschmid@users.sourceforge.net>

function f = isposint(n)

  ## check range of input arguments
  error(nargchk(1,1,nargin))
  
  ## check input arg
  if (length(n)>1)
    error("Input argument must not be a vector, only scalars are allowed!")
  endif

  f = 1;
  if ( (!isreal(n)) | (n<=0) | (round(n) != n) )
    f = 0;
  endif

endfunction