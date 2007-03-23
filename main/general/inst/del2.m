## Copyright (C) 2000  Kai Habel
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{D} =} del2 (@var{M})
## @deftypefnx {Function File} {@var{D} =}del2 (@var{M}, @var{dx}, @var{dy})
##
## @var{D} = del2 (@var{M}) calculates the Laplace Operator
##
## @example
##       1    / d^2            d^2         \
## D  = --- * | ---  M(x,y) +  ---  M(x,y) | 
##       4    \ dx^2           dx^2        /
## @end example
##
## Spacing values for x and y direction can be provided by the
## @var{dx}, @var{dy} parameters, otherwise the spacing is set to 1.
## A scalar value specifies an equidistant spacing.
## A vector value can be used to specify a variable spacing. The length
## must match the respective dimension of @var{M}.
##
## You need at least 3 data points for each dimension.
## Boundary points are calculated with y0'' and y2'' respectively.
## For interior point y1'' is taken. 
##
## @example
## y0''(i) = 1/(dy^2) *(y(i)-2*y(i+1)+y(i+2)).
## y1''(i) = 1/(dy^2) *(y(i-1)-2*y(i)+y(i+1)).
## y2''(i) = 1/(dy^2) *(y(i-2)-2*y(i-1)+y(i)).
## @end example
##
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>

function D = del2 (M, dx, dy)
  
  if ((nargin < 1) || (nargin > 3))
    usage ("del2(M,dx,dy)");
  elseif (nargin == 1)
    dx = dy = 1;
  elseif (nargin == 2)
    dy = 1;
  endif

  if (!is_matrix (M))
    error ("first argument must be a matrix");
  else
    if is_scalar (dx)
      dx = dx * ones (1, columns(M) - 1);
    else
      if !(length(dx) == columns(M))
        error ("columns of M must match length of dx")
      else
        dx = diff (dx);
      endif
    endif

    if (is_scalar (dy))
      dy = dy * ones (rows (M) - 1, 1);
    else
      if !(length(dy) == rows(M))
        error ("rows of M must match length of dy")
      else
        dy = diff (dy);
      endif
    endif
  endif

  [mr,mc] = size (M);
  D = zeros (size (M));

  if (mr >= 3)  
    ## x direction
    ## left and right boundary
    D(:, 1) = (M(:, 1) .- 2 * M(:, 2) + M(:, 3)) / (dx(1) * dx(2));
    D(:, mc) = (M(:, mc - 2) .- 2 * M(:, mc - 1) + M(:, mc))\
      / (dx(mc - 2) * dx(mc - 1));

    ## interior points
    D(:, 2:mc - 1) = D(:, 2:mc - 1)\
      + (M(:, 3:mc) .- 2 * M(:, 2:mc - 1) + M(:, 1:mc - 2))\
      ./ kron (dx(1:mc -2 ) .* dx(2:mc - 1), ones (mr, 1));
  endif

  if (mc >= 3)
    ## y direction
    ## top and bottom boundary
    D(1, :) = D(1,:)\
      + (M(1, :) .- 2 * M(2, :) + M(3, :)) / (dy(1) * dy(2));
    D(mr, :) = D(mr, :)\
      + (M(mr - 2,:) .- 2 * M(mr - 1, :) + M(mr, :))\
      / (dy(mr - 2) * dx(mr - 1));
    
    ## interior points
    D(2:mr - 1, :) = D(2:mr - 1, :)\
      + (M(3:mr, :) .- 2 * M(2:mr - 1, :) + M(1:mr - 2, :))\
      ./ kron (dy(1:mr - 2) .* dy(2:mr - 1), ones (1, mc));
  endif

  D = D ./ 4;
endfunction
