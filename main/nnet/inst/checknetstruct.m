## Copyright (C) 2006 Michel D. Schmid   <email: michaelschmid@users.sourceforge.net>
##
## This program is part of Octave.
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
## @deftypefn {Function File} {}[@var{isTrue}] = checknetstruct (@var{net})
## This function will check if a valid structure seems to be a neural network
## structure
##
## @noindent
##
## left side arguments:
## @noindent
##
## right side arguments:
## @noindent
##
##
## @noindent
## are equivalent.
## @end deftypefn

## @seealso{newff,prestd,trastd}

## Author: mds
## $LastChangedDate: 2006-08-20 21:47:51 +0200 (Sun, 20 Aug 2006) $
## $Rev: 38 $


function isTrue = checknetstruct(net)

  isTrue = 0;
  ## first check, if it's a structure
  if isstruct(net)
    if ( isfield(net,"numInputs") & isfield(net,"inputs") & isfield(net,"IW")\
        & isfield(net,"trainFcn") )
				isTrue = 1;
    endif
  else
    return;
  endif

endfunction