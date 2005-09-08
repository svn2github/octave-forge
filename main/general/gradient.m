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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{X} = } gradient (@var{M})
## @deftypefnx {Function File} {[@var{X},@var{Y}] = }gradient (@var{M})
## @deftypefnx {Function File} {[...] = }gradient (...,@var{dx},@var{dy})
##
## @var{X} = gradient (@var{M}) calculates the one dimensional
## gradient if M is a vector. Is M a Matrix the gradient is calculated 
## for each row.
## [@var{X},@var{Y}] = gradient (@var{M}) calculates the one dimensinal
## gradient for each direction if @var{M} is a matrix.
## Spacing values between two points can be provided by the
## @var{dx}, @var{dy} parameters, otherwise the spacing is set to 1.
## A scalar value specifies an equidistant spacing.
## A vector value can be used to specify a variable spacing. The length
## must match their respective dimension of @var{M}.
## 
## At boundary points a linear extrapolation is applied. Interior points
## are calculated with the first approximation of the numerical gradient
## @example
## y'(i) = 1/(x(i+1)-x(i-1)) *(y(i-1)-y(i+1)).
## @end example
## 
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>

function [varargout] = gradient (M, dx, dy)
  
  if ((nargin < 1) || (nargin > 3))
    usage ("gradient(M,dx,dy)");
  elseif (nargin == 1)
    dx = dy = 1;
  elseif (nargin == 2)
    dy = 1;
  endif

  if (isvector (M))
    ## make a row vector
    M = M(:)';
  endif

  if !(is_matrix (M))
    error ("first argument must be a vector or matrix");
  else
    if (is_scalar (dx))
      dx = dx * ones (1, columns (M) - 1);
    else
      if (length (dx) != columns (M))
        error ("columns of M must match length of dx");
      else
        dx = diff (dx);
        dx = dx(:)';
      endif
    endif

    if (is_scalar (dy))
      dy = dy * ones (rows (M) - 1, 1);
    else
      if (length (dy) != rows (M))
        error ("rows of M must match length of dy")
      else
        dy = diff (dy);
      endif
    endif
  endif
  [mr, mc] = size (M);
  X = zeros (size (M));

  if (mc > 1)
    ## left and right boundary
    X(:, 1) = diff (M(:, 1:2)')' / dx(1);
    X(:,mc) = diff (M(:, mc - 1:mc)')' / dx(mc - 1);
  endif

  if (mc > 2)
    ## interior points
    X(:, 2:mc - 1) = (M(:, 3:mc) .- M(:,1:mc - 2))\
      ./ kron (dx(1:mc - 2) .+ dx(2:mc - 1), ones (mr, 1));
    #  ./ (ones (mr, 1) * (dx(1:mc - 2) .+ dx(2:mc - 1)));
  endif
  vr_val_cnt = 1; varargout{vr_val_cnt++} = X;

  if (nargout == 2)
    Y = zeros (size (M));
    if (mr > 1)
      ## top and bottom boundary
      Y(1, :) = diff (M(1:2, :)) / dy(1);
      Y(mr, :) = diff (M(mr - 1:mr, :)) / dy(mr - 1);
    endif

    if (mr > 2)
      ## interior points
      Y(2:mr-1, :) = (M(3:mr, :) .- M(1:mr - 2, :))\
        ./kron (dy(1:mr - 2) .+ dy(2:mr - 1), ones(1, mc));
    endif
    varargout{vr_val_cnt++} = Y;
  
  endif
endfunction
