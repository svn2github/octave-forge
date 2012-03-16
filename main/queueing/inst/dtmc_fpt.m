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
##
## @cindex First passage times
## @cindex Mean recurrence times
##
## Compute the mean first passage times matrix @math{\bf M}, such that
## @code{@var{M}(i,j)} is the average number of transitions before state
## @var{j} is reached, starting from state @var{i}, for all @math{1 \leq
## i, j \leq N}. Diagonal elements of @var{M} are the mean recurrence
## times.
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
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item M
## @code{@var{M}(i,j)} is the average number of transitions before state
## @var{j} is reached for the first time, starting from state @var{i}.
## @code{@var{M}(i,i)} is the @emph{mean recurrence time} of state
## @math{i}, and represents the average time needed to return to state
## @var{i}.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function result = dtmc_fpt( P )

  if ( nargin != 1 )
    print_usage();
  endif

  [N err] = dtmc_check_P(P);

  ( N>0 ) || \
      error(err);

  if ( any(diag(P) == 1) ) 
    error("Cannot compute first passage times for absorbing chains");
  endif

  w = dtmc(P);
  W = repmat(w,N,1);
  Z = inv(eye(N)-P+W);
  result = (repmat(diag(Z)',N,1) - Z) ./ repmat(w,N,1) + diag(1./w);

#{
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
    (isscalar(i) && i>=1 && j<=N) || \
	usage("i must be an integer in the range [1,%d]", N);
    (isvector(j) && all(j>=1) && all(j<=N)) || \
	usage("j must be an integer or vector with elements in [1,%d]", N);
    j = j(:)'; # make j a row vector
    b = ones(N,1);
    A = -P;
    A(:,j) = 0;
    A += eye(N,N);
    res = A \ b;
    result = res(i);
  endif
#}

endfunction
%!test
%! P = [1 1 1; 1 1 1];
%! fail( "dtmc_fpt(P)" );

%!test
%! P = dtmc_bd([1 1 1], [0 0 0] );
%! fail( "dtmc_fpt(P)", "absorbing" );

%!test
%! P = [ 0.0 0.9 0.1; \
%!       0.1 0.0 0.9; \
%!       0.9 0.1 0.0 ];
%! p = dtmc(P);
%! M = dtmc_fpt(P);
%! assert( diag(M)', 1./p, 1e-8 );

## Example on p. 461 of
## http://www.cs.virginia.edu/~gfx/Courses/2006/DataDriven/bib/texsyn/Chapter11.pdf
%!test
%! P = [ 0 1 0 0 0; \
%!      .25 .0 .75 0 0; \
%!      0 .5 0 .5 0; \
%!      0 0 .75 0 .25; \
%!      0 0 0 1 0 ];
%! M = dtmc_fpt(P);
%! assert( M, [16 1 2.6667 6.3333 21.3333; \
%!             15 4 1.6667 5.3333 20.3333; \
%!             18.6667 3.6667 2.6667 3.6667 18.6667; \
%!             20.3333 5.3333 1.6667 4 15; \
%!             21.3333 6.3333 2.6667 1 16 ], 1e-4 );

%!test
%! sz = 10;
%! P = reshape( 1:sz^2, sz, sz );
%! normP = repmat(sum(P,2),1,columns(P));
%! P = P./normP;
%! M = dtmc_fpt(P);
%! for i=1:rows(P)
%!   for j=1:columns(P)
%!     assert( M(i,j), 1 + dot(P(i,:), M(:,j)) - P(i,j)*M(j,j), 1e-8);
%!   endfor
%! endfor

%!demo
%! P = [ 0.0 0.9 0.1; \
%!       0.1 0.0 0.9; \
%!       0.9 0.1 0.0 ];
%! M = dtmc_fpt(P);
%! w = dtmc(P);
%! N = rows(P);
%! W = repmat(w,N,1);
%! Z = inv(eye(N)-P+W);
%! M1 = (repmat(diag(Z),1,N) - Z) ./ repmat(w',1,N);
%! assert(M, M1);

