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
## @deftypefn {Function File} {@var{M} =} ctmc_fpt (@var{Q})
## @deftypefnx {Function File} {@var{m} =} ctmc_fpt (@var{Q}, @var{i}, @var{j})
##
## @cindex Markov chain, continuous time
## @cindex First passage times
##
## If called with a single argument, computes the mean first passage
## times @code{@var{M}(i,j)}, the average times before state @var{j} is
## reached, starting from state @var{i}, for all @math{1 \leq i, j \leq
## N}. If called with three arguments, returns the single value
## @code{@var{m} = @var{M}(i,j)}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item Q
## Infinitesimal generator matrix. @var{Q} is a @math{N \times N} square
## matrix where @code{@var{Q}(i,j)} is the transition rate from state
## @math{i} to state @math{j}, for @math{1 @leq{} i \neq j @leq{} N}.
## Transition rates must be nonnegative, and @math{\sum_{j=1}^N Q_{i j} = 0}
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
## @code{@var{M}(i,j)} is the average time before state
## @var{j} is visited for the first time, starting from state @var{i}.
##
## @item m
## If this function is called with three arguments, the result
## @var{m} is the average time before state @var{j} is visited for the first 
## time, starting from state @var{i}.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function result = ctmc_fpt( Q, i, j )

  persistent epsilon = 10*eps;

  if ( nargin != 1 && nargin != 3 )
    print_usage();
  endif

  issquare(Q) || \
      usage( "Q must be a square matrix" );

  N = rows(Q);

  ( norm( sum(Q,2), "inf" ) < epsilon ) || \
      usage( "Q is not an infinitesimal generator matrix" );

  if ( nargin == 1 ) 
    M = zeros(N,N);
    for j=1:N
      QQ = Q;
      QQ(j,:) = 0; # make state j absorbing
      for i=1:N
	p0 = zeros(1,N); p0(i) = 1;
	M(i,j) = ctmc_mtta(QQ,p0);
      endfor
    endfor
    result = M;
  else
    (isscalar(i) && i>=1 && j<=N) || usage("i must be an integer in the range 1..%d", N);
    (isvector(j) && all(j>=1) && all(j<=N)) || usage("j must be an integer or vector with elements in 1..%d", N);
    j = j(:)'; # make j a row vector
    Q(j,:) = 0; # make state(s) j absorbing
    p0 = zeros(1,N); p0(i) = 1;
    result = ctmc_mtta(Q,p0);    
  endif
endfunction
%!demo
%! Q = [ -1.0  0.9  0.1; \
%!        0.1 -1.0  0.9; \
%!        0.9  0.1 -1.0 ];
%! M = ctmc_fpt(Q)
%! m = ctmc_fpt(Q,1,3)

%!xtest
%! Q = unifrnd(0.1,0.9,10,10);
%! Q -= diag(sum(Q,2));
%! M = ctmc_fpt(Q);

%!xtest
%! Q = unifrnd(0.1,0.9,10,10);
%! Q -= diag(sum(Q,2));
%! m = ctmc_fpt(Q,1,3);

%!xtest
%! Q = unifrnd(0.1,0.9,10,10);
%! Q -= diag(sum(Q,2));
%! m = ctmc_fpt(Q,1,[3 5 6]);
