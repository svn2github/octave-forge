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
## @deftypefn {Function File} {@var{p} =} dtmc (@var{P})
## @deftypefnx {Function File} {@var{p} =} dtmc (@var{P}, @var{n}, @var{p0})
##
## @cindex Markov chain, discrete time
## @cindex Discrete time Markov chain
## @cindex Markov chain, stationary probabilities
## @cindex Stationary probabilities
## @cindex Markov chain, transient probabilities
## @cindex Transient probabilities
##
## Compute steady-state or transient state occupancy probabilities for a
## Discrete-Time Markov Chain. With a single argument, compute the
## steady-state occupancy probability vector @code{@var{p}(1), @dots{},
## @var{p}(N)} given the @math{N \times N} transition probability matrix
## @var{P}. With three arguments, compute the state occupancy
## probabilities @code{@var{p}(1), @dots{}, @var{p}(N)} after @var{n}
## steps, given initial occupancy probability vector @var{p0}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## @code{@var{P}(i,j)} is the transition probability from state @math{i}
## to state @math{j}. @var{P} must be an irreducible stochastic matrix,
## which means that the sum of each row must be 1 (@math{\sum_{j=1}^N P_{i j} = 1}), and the rank of
## @var{P} must be equal to its dimension.
##
## @item n
## Step at which to compute the transient probability
##
## @item p0
## @code{@var{p0}(i)} is the probability that at step 0 the system
## is in state @math{i}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item p
## If this function is invoked with a single argument,
## @code{@var{p}(i)} is the steady-state probability that the system is
## in state @math{i}. @var{p} satisfies the equations @math{p = p{\bf P}} and @math{\sum_{i=1}^N p_i = 1}. If this function is invoked
## with three arguments, @code{@var{p}(i)} is the marginal probability
## that the system is in state @math{i} at step @var{n},
## given the initial probabilities @code{@var{p0}(i)} that the initial state is
## @math{i}.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function q = dtmc( P, n, p0 )

  persistent epsilon = 10*eps;

  if ( nargin < 1 || nargin > 3 )
    print_usage();
  endif

  [N err] = dtmc_check_P(P);
  
  ( N>0 ) || \
      usage( err );
  
  if ( nargin > 1 )
    ( isscalar(n) && n>=0 ) || \
	usage( "n must be >=0" );
  endif

  if ( nargin > 2 )
    ( isvector(p0) && length(p0) == N && all(p0>=0) && abs(sum(p0)-1.0)<epsilon ) || \
        usage( "p0 must be a probability vector" );   
    p0 = p0(:)'; # make q0 a row vector
  else
    p0 = ones(1,N) / N;
  endif

  if ( nargin == 1 )
    q = __dtmc_steady_state( P );
  else
    q = __dtmc_transient(P, n, p0);
  endif
endfunction

## Helper function, compute steady-state probability
function q = __dtmc_steady_state( P )
  N = rows(P);
  A = P-eye(N);
  A(:,N) = 1; # add normalization condition
  rank( A ) == N || \
      warning( "dtmc(): P is reducible" );

  b = [ zeros(1,N-1) 1 ];
  q = b/A;
endfunction

## Helper function, compute transient probability
function q = __dtmc_transient( P, n, p0 )
  q = p0*P^n;
endfunction

%!test
%! P = [0.75 0.25; 0.5 0.5];
%! q = dtmc(P);
%! assert( q*P, q, 1e-5 );
%! assert( q, [0.6666 0.3333], 1e-4 );

%!test
%! #Example 2.11 p. 44 Bolch et al.
%! P = [0.5 0.5; 0.5 0.5];
%! q = dtmc(P);
%! assert( q, [0.5 0.5], 1e-3 );

%!test
%! fail("dtmc( [1 1 1; 1 1 1] )", "square");

%!test
%! a = 0.2;
%! b = 0.8;
%! P = [1-a a; b 1-b];
%! plim = dtmc(P);
%! p = dtmc(P, 100, [1 0]);
%! assert( plim, p, 1e-5 );

%!test
%! P = [0 1 0 0 0; \
%!      .25 0 .75 0 0; \
%!      0 .5 0 .5 0; \
%!      0 0 .75 0 .25; \
%!      0 0 0 1 0 ];
%! p = dtmc(P);
%! assert( p, [.0625 .25 .375 .25 .0625], 10*eps );

%!demo
%! a = 0.2;
%! b = 0.15;
%! P = [ 1-a a; b 1-b];
%! T = 0:14;
%! pp = zeros(2,length(T));
%! for i=1:length(T)
%!   pp(:,i) = dtmc(P,T(i),[1 0]);
%! endfor
%! ss = dtmc(P); # compute steady state probabilities
%! plot( T, pp(1,:), "b+;p_0(t);", "linewidth", 2, \
%!       T, ss(1)*ones(size(T)), "b;Steady State;", \
%!       T, pp(2,:), "r+;p_1(t);", "linewidth", 2, \
%!       T, ss(2)*ones(size(T)), "r;Steady State;" );
%! xlabel("Time Step");
