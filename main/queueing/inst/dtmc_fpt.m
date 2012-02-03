## Copyright (C) 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {@var{M} =} dtmc_fpt (@var{P})
## @deftypefnx {Function File} {@var{m} =} dtmc_fpt (@var{P}, @var{i}, @var{j})
##
## @cindex Markov chain, discrete time
## @cindex First passage times
##
## If called with a single argument, computes the mean first passage
## times @code{@var{M}(i,j)}, that are the average number of transitions before
## state @var{j} is reached, starting from state @var{i}, for all
## @math{1 \leq i, j \leq N}. If called with three arguments, returns
## the single value @code{@var{m} = @var{M}(i,j)}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## @code{@var{P}(i,j)} is the transition probability from state @math{i}
## to state @math{j}. @var{P} must be an irreducible stochastic matrix,
## which means that the sum of each row must be 1 (@math{\sum_{j=1}^N
## P_{i j} = 1}), and the rank of @var{P} must be equal to its
## dimension.
##
## @item i
## Initial state.
##
## @item j
## Destination state. If @var{j} is a vector, returns the mean first passage
## time to any state in @var{j}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item M
## If this function is called with a single argument, the result
## @code{@var{M}(i,j)} is the average number of transitions before state
## @var{j} is reached for the first time, starting from state @var{i}.
##
## @item m
## If this function is called with three arguments, the result @var{m}
## is the average number of transitions before state @var{j} is visited
## for the first time, starting from state @var{i}.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function result = dtmc_fpt( P, i, j )
  persistent epsilon = 10*eps;

  if ( nargin != 1 && nargin != 3)
    print_usage();
  endif

  issquare(P) || \
      usage( "P must be a square matrix" );

  N = rows(P);
  
  ( all(P >= 0 ) && norm( sum(P,2) - 1, "inf" ) < epsilon ) || \
      usage( "P is not a stochastic matrix" );

  if ( nargin == 1 )   
    M = zeros(N,N);
    ## M(i,j) = 1 + sum_{k \neq j} P(i,k) M(k,j)
    b = ones(N,1);
    for j=1:N
      A = -P;
      A(:,j) = 0;
      A += eye(N,N);
      res = A \ b;
      M(:,j) = res';
    endfor
    result = M;
  else
    (isscalar(i) && i>=1 && j<=N) || usage("i must be an integer in the range [1,%d]", N);
    (isvector(j) && all(j>=1) && all(j<=N)) || usage("j must be an integer or vector with elements in 1..%d", N);
    j = j(:)'; # make j a row vector
    b = ones(N,1);
    A = -P;
    A(:,j) = 0;
    A += eye(N,N);
    res = A \ b;
    result = res(i);
  endif
endfunction
%!demo
%! P = [ 0.0 0.9 0.1; \
%!       0.1 0.0 0.9; \
%!       0.9 0.1 0.0 ];
%! M = dtmc_fpt(P);

%!test
%! P = [ 0.0 0.9 0.1; \
%!       0.1 0.0 0.9; \
%!       0.9 0.1 0.0 ];
%! p = dtmc(P);
%! M = dtmc_fpt(P);
%! assert( diag(M)', 1./p, 1e-8 );

%!test
%! P = [ 0.0 0.9 0.1; \
%!       0.1 0.0 0.9; \
%!       0.9 0.1 0.0 ];
%! p = dtmc(P);
%! m = dtmc_fpt(P, 1, 1);
%! assert( m, 1/p(1), 1e-8 );

%!test
%! P = [ 0.0 0.9 0.1; \
%!       0.1 0.0 0.9; \
%!       0.9 0.1 0.0 ];
%! m = dtmc_fpt(P, 1, [2 3]);

%!test
%! P = unifrnd(0.1,0.9,10,10);
%! normP = repmat(sum(P,2),1,columns(P));
%! P = P./normP;
%! M = dtmc_fpt(P);
%! for i=1:rows(P)
%!   for j=1:columns(P)
%!     assert( M(i,j), 1 + dot(P(i,:), M(:,j)) - P(i,j)*M(j,j), 1e-8);
%!     assert( M(i,j), dtmc_fpt(P, i, j), 1e-8 );
%!   endfor
%! endfor
