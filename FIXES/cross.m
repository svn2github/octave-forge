## Copyright (C) 1995, 1996  Kurt Hornik
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file.  If not, write to the Free Software Foundation,
## 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} cross (@var{x}, @var{y})
## Computes the vector cross product of the two 3-dimensional vectors
## @var{x} and @var{y}.
##
## @example
## @group
## cross ([1,1,0], [0,1,1])
##      @result{} [ 1; -1; 1 ]
## @end group
## @end example
##
## If @var{x} and @var{y} are two - dimensional matrices the
## cross product is applied along the first dimension with 3 elements.
##
## If cross is given a row vector and a column vector, then it will
## issue a warning and return a column vector.
##
## @end deftypefn

## Author: KH <Kurt.Hornik@ci.tuwien.ac.at>
## Created: 15 October 1994
## Adapted-By: jwe

## 2001-10-22 Paul Kienzle
## * handle matrix inputs
## * output row vector if either input is a row vector
## 2001-10-22 Paul Kienzle
## * restore octave orientation for mismatched vectors, but issue a warning
function z = cross (x, y)
	
  if (nargin != 2)
    usage ("cross (x, y)");
  endif

  ## XXX COMPATIBILITY XXX opposite behaviour for cross(row,col)
  ## Swap x and y in the assignments below to get the matlab behaviour.
  ## Better yet, fix the calling code so that it uses conformant vectors.
  if (columns(x) == 1 && rows(y) == 1)
    warning ("cross: taking cross product of column by row");
    y = y.';
  elseif (rows(x) == 1 && columns(y) == 1)
    warning ("cross: taking cross product of row by column");
    x = x.';
  endif

  if (size(x) == size(y))
    if (rows(x) == 3)
      z = [x(2,:).*y(3,:) - x(3,:).*y(2,:)
           x(3,:).*y(1,:) - x(1,:).*y(3,:)
           x(1,:).*y(2,:) - x(2,:).*y(1,:)];
    elseif (columns(x) == 3)
      z = [x(:,2).*y(:,3) - x(:,3).*y(:,2)\
           x(:,3).*y(:,1) - x(:,1).*y(:,3)\
           x(:,1).*y(:,2) - x(:,2).*y(:,1)];
    else
      error ("cross: x,y must have dimension nx3 or 3xn");
    endif
  else
    error ("cross: x and y must have the same dimensions");
  endif

endfunction
