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

## [B,c] = spdiags(A): extract all non-zero diagonals of A.
## B = spdiags(A,c): extract diagonals c of A.
## A = spdiags(v,c,A): use columns of v to replace the diagonals c of A
## A = spdiags(v,c,m,n): use columns of v as the diagonals c of mxn matrix A
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
function [A, c] = spdiags(v,c,m,n)

  dfi = do_fortran_indexing;
  unwind_protect
    do_fortran_indexing = 1;
    
    if nargin == 1 || nargin == 2
      ## extract nonzero diagonals of v into A,c
      [i,j,v,nr,nc] = spfind(v);
      if nargin == 1
        c = unique(j-i);  # c contains the active diagonals
      endif
      ## FIXME: we can do this without a loop if we are clever
      offset = max(min(c,nc-nr),0);
      A = zeros(min(nr,nc),length(c));
      for k=1:length(c)
	idx = find(j-i == c(k));
	A(j(idx)-offset(k),k) = v(idx);
      end

    elseif nargin == 3
      ## Replace specific diagonals c of m with v,c
      [nr,nc] = size(m);
      B = spdiags(m,c);
      A = m - spdiags(B,c,nr,nc) + spdiags(v,c,nr,nc);
      
    else
      ## Create new matrix of size mxn using v,c
      [j,i,v] = find(v);
      offset = max(min(c,n-m),0);
      j+=offset(i);
      i=j-c(i);
      A = sparse(i,j,v,m,n);
      
    endif
    
  unwind_protect_cleanup
    do_fortran_indexing = dfi;
  end_unwind_protect

endfunction
