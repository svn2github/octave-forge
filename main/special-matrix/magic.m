## Copyright (C) 1999-2001 Paul Kienzle
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

## magic(n)
## Create an n-by-n magic square.
## Note that magic(2) is undefined since there is no 2x2 magic square.

function A = magic(n)

  if nargin != 1 || n != floor(n) || n < 0 || n == 2
    usage("magic (n), n != 2");
  endif

  if (n == 0)

    A=[];

  elseif (mod(n,2) == 1)

    shift = floor((0:n*n-1)/n);
    c = mod ([1:n*n] - shift + (n-3)/2, n);
    r = mod ([n*n:-1:1] + 2*shift, n);
    A (c*n+r+1) = 1:n*n;
    A = reshape (A, n, n);

  elseif (mod(n,4) == 0)

    A = reshape (1:n*n, n, n)';
    I = [ 1:4:n, 4:4:n ]; J = fliplr(I);
    A (I, I) = A (J, J);
    I = [ 2:4:n, 3:4:n ]; J = fliplr(I);
    A (I, I) = A (J, J);

  elseif (mod(n,4) == 2)

    m = n/2;
    A = magic (m);
    A = [ A, A+2*m*m; A+3*m*m, A+m*m ];
    k = (m-1)/2;
    if (k>1)
      I = [ 1 : m ];
      J = [ 2:k, n-k+2:n ];
      A ([I,I+m], J) = A ([I+m,I], J);
    endif
    I = [1:k, k+2:m];
    A ([I,I+m], 1) = A ([I+m,I], 1);
    I = k + 1;
    A ([I,I+m], I) = A ([I+m,I], I);
  
  endif

endfunction

%!test
%! for i=3:30
%!   A=magic(i);
%!   assert(norm(diff([sum(diag(A)),sum(diag(flipud(A))),sum(A),sum(A')])),0)
%! endfor
%!assert(isempty(magic(0)));
%!assert(magic(1),1);
%!error magic(2)
