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
## @deftypefn {Function File} {@var{I} =} trapz (@var{Y})
## @deftypefnx {Function File} {@var{I} =}trapz (@var{X},@var{Y})
## 
## numerical intergration using trapezodial method.
## trapz (@var{y}) computes the integral of the vector y. If y is a 
## matrix the integral is computed columnwise.
## If the argument @var{X} is omitted a equally spaced vector is assumed. 
## trapz (@var{X},@var{Y}) evaluates the integral with respect to @var{X}
##  
## @seealso{cumtrapz}
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
##
## also: June 2000 - Paul Kienzle (fixes,suggestions) 

function I = trapz (X, Y)
	
  if (nargin < 1) || (nargin > 2)
    usage ("trapz (X, Y)");
  elseif (nargin == 1)

    if !(is_matrix (X))
      error ("argument must be vector or matrix");
    endif
    
    if (is_vector(X))
      X=X(:);
    endif

    r = rows(X);
	
    tmp = X (2:r, :) .+ X (1:r-1,:);

    if (rows(tmp) == 1)
      I = 0.5 * tmp;
    else
      I = 0.5 * sum (tmp);
    endif

  elseif (nargin == 2)

    if !(is_matrix (X) && is_matrix (Y))
      error ("arguments must be vectors or matrices of same size");
    endif

    if (size (X) == size (Y'))
      Y = Y';
    elseif (size (X) != size (Y))
      error ("X and Y must have same shape");
    endif

    if (is_vector (X))
      X = X (:); Y = Y (:);
    endif

    r = rows (X);
	
    tmp = (X(2:r, :) .- X(1:r-1,:)) .* (Y(2:r,:) .+ Y(1:r - 1, :));

    if (rows(tmp) == 1)
      I = 0.5 * tmp;
    else
      I = 0.5 * sum (tmp);
    endif

  endif
endfunction
