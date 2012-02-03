## Copyright (C) 2008, 2009, 2010, 2011, 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {[@var{T} @var{p}] =} blkdiagonalize (@var{M})
##
## @strong{WARNING: this function has not been sufficiently tested}
##
## Given a square matrix @var{M}, return a new matrix @code{@var{T} =
## @var{M}(@var{p},@var{p})} such that @var{T} is in block triangular
## form.
##
## @strong{INPUTS}
##
## @table @var
##
## @item M 
##
## Square matrix to be permuted in block-triangular form
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item T
##
## The matrix @var{M} permuted in block-triangular form
##
## @item p
##
## Vector representing the permutation. The matrix @var{T}
## can be derived as @code{@var{T} = @var{M}(@var{p},@var{p})}
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [T p] = blkdiagonalize( M )
  if ( nargin =! 1 )
    print_usage();
  endif
  n = rows(M);
  ( [n,n] == size(M) ) || \
      error( "M must be a square matrix" );
  p = linspace(1,n,n); # identify permutation
  T = M;
  for i=1:n-1 # loop over rows
    ## find zero and nonzero elements in the i-th row
    zel = find(T(i,:)==0);
    nzl = find(T(i,:)!=0);
    zeroel = zel(zel>i);
    nzeroel = nzl(nzl>i);
    perm = [ 1:i nzeroel zeroel ];
    
    ## Update permutation
    p = p(perm);
    ## Permute matrix
    T = T(perm,perm);
  endfor
endfunction
%!demo
%! P = [0 0.4 0 0 0.3 0 0 0.3 0; ...
%!      0.3 0 0 0 0 0 0 0.7 0; ...      
%!      0 0 0 0 0 0.3 0 0 0.7; ...
%!      0 0 0 0 1 0 0 0 0; ...
%!      0.3 0 0 0 0 0 0.7 0 0; ...
%!      0 0 0.3 0 0 0 0 0 0.7; ...
%!      1.0 0 0 0 0 0 0 0 0; ...
%!      0 0 0 1.0 0 0 0 0 0; ...
%!      0 0 0.4 0 0 0.6 0 0 0];
%! P = blkdiagonalize(P);
%! spy(P);

%!demo
%! A = ones(3);
%! B = 2*ones(2);
%! C = 3*ones(3);
%! D = 4*ones(7);
%! E = 5*ones(2);
%! M = blkdiag(A, B, C, D, E);
%! n = rows(M);
%! spy(M);
%! printf("Press any key or wait 5 seconds...");
%! pause(5);
%! p = randperm(n);
%! M = M(p,p);
%! spy(M);
%! printf("Scrambled matrix. Press any key or wait 5 seconds...");
%! pause(5);
%! T = blkdiagonalize(M);
%! spy(T);
%! printf("Unscrambled matrix" );

%!xtest
%! A = ones(3);
%! B = 2*ones(2);
%! C = 3*ones(3);
%! D = 4*ones(7);
%! E = 5*ones(2);
%! M = blkdiag(A, B, C, D, E);
%! n = rows(M);
%! p = randperm(n);
%! Mperm = M(p,p);
%! T = blkdiagonalize(Mperm);
%! assert( T, M );

## Given a block diagonal matrix M, find the size of all blocks. b(i) is
## the size of i-th along the diagonal. A zero matrix is considered to
## have a single block of size equal to the size of the matrix.
function b = findblocks(M)
  n = rows(M);
  (size(M) == [n,n]) || \
      error("M must be a square matrix");
  b = [];
  i=d=1;
  while( d<n )
    bb = M(i:d,i:d);
    z1 = M(i:d,d+1:n);
    z2 = M(d+1:n,i:d);
    if ( any(bb) && !any(z1) && !any(z2) )
      b = [b d-i+1];
      i=d+1;
      d=i;
    else
      d++;
    endif
  endwhile
  if (i<d)
    b = [b d-i+1];
  endif
endfunction
