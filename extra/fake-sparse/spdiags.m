## Copyright (C) 2000-2001 Paul Kienzle
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

## spdiags(A): extract all non-zero diagonals of A.
## spdiags(A,c): extract diagonals c of A.
## spdiags(v,c,A): use columns of v to replace the diagonals c of A
## spdiags(v,c,m,n): use columns of v as the diagonals c of mxn matrix A
##
## -c lower diagonal, 0 main diagonal, +c upper diagonal
## E.g.,
##
## v-> 1  5  9
##     2  6 10
##     3  7 11
##     4  8 12
## spdiags(v, [-1 0 1], 5, 4)
## ->  5 10  0  0
##     1  6 11  0
##     0  2  7 12
##     0  0  3  8
##     0  0  0  4
## Fake sparse function: represents sparse matrices using full matrices
function [A, c] = spdiags(v,c,m,n)

  dfi = do_fortran_indexing;
  unwind_protect
    do_fortran_indexing = 1;
    
    if nargin == 1
      ## extract nonzero diagonals of v into A,c
      [m, n] = size(v);
      nr = n;
      nc = m + n - 1;
      c = -m+1:n-1;
      A = zeros(nr,nc);
      ridx = [1:nr]'*ones(1,nc) - ones(nr,1)*c(:)';
      Aidx = ridx + m*[0:nr-1]'*ones(1,nc);
      idx = find(ridx > 0 & ridx <= m);
      A(idx) = v(Aidx(idx));
      c = find (any (A != 0));
      A = A(:,c);
      c = c - m;

    elseif nargin == 2
      ## extract specific diagonals c of v into A
      nr = size(v,2);
      nc = length(c(:));
      A = zeros(nr,nc);
      [m, n] = size(v);
      ridx = [1:nr]'*ones(1,nc) - ones(nr,1)*c(:)';
      Aidx = ridx + m*[0:nr-1]'*ones(1,nc);
      idx = find(ridx > 0 & ridx <= m);
      A(idx) = v(Aidx(idx));

    elseif nargin == 3
      ## Replace specific diagonals c of m with v,c
      A = m;
      [m, n] = size(A);
      [nr, nc] = size(v);
      ridx = [1:nr]'*ones(1,nc) - ones(nr,1)*c(:)';
      Aidx = ridx + m*[0:nr-1]'*ones(1,nc);
      idx = find(ridx > 0 & ridx <= m);
      A(Aidx(idx)) = v(idx);
      
    else
      ## Create new matrix of size mxn using v,c
      A = zeros(m,n);
      [nr, nc] = size(v);
      ridx = [1:nr]'*ones(1,nc) - ones(nr,1)*c(:)';
      Aidx = ridx + m*[0:nr-1]'*ones(1,nc);
      idx = find(ridx > 0 & ridx <= m);
      A(Aidx(idx)) = v(idx);
      
    endif
    
  unwind_protect_cleanup
    do_fortran_indexing = dfi;
  end_unwind_protect

endfunction