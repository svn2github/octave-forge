## Copyright (C) 1999 Peter Ekberg
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
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## usage: pascal (n, t)
##
## Return the Pascal matrix of order n if t=0.
## t defaults to 0.
## Return lower triangular Cholesky factor of the Pascal matrix if t=1.
## Return a transposed and permuted version of pascal(n,1) if t=2.
##
## pascal(n,1)^2 == eye(n)
## pascal(n,2)^3 == eye(n)
##
## See also: hankel, vander, sylvester_matrix, hilb, invhilb, toeplitz
##           hadamard, wilkinson, rosser, compan

## Author: Peter Ekberg
##         (peda)

function retval = pascal (n, t)

  if (nargin > 2) || (nargin == 0)
    usage ("pascal (n, t)");
  endif

  if (nargin == 1)
    t = 0;
  endif

  if !is_scalar (n) || !is_scalar (t)
    error ("pascal expecting scalar arguments, found something else");
  endif

  retval = diag((-1).^[0:n-1]);
  retval(:,1) = ones(n, 1);

  for j=2:n-1
    for i=j+1:n
      retval(i,j) = retval(i-1,j) - retval(i-1,j-1);
    endfor
  endfor

  if (t==0)
    retval = retval*retval';
  elseif (t==2)
    retval = retval';
    retval = retval(n:-1:1,:);
    retval(:,n) = -retval(:,n);
    retval(n,:) = -retval(n,:);
    if (rem(n,2) != 1)
      retval = -retval;
    endif
  endif

endfunction
