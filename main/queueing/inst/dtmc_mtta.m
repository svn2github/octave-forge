## Copyright (C) 2012 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{t} @var{B}] =} dtmc_mtta (@var{P})
## @deftypefnx {Function File} {[@var{t} @var{B}] =} dtmc_mtta (@var{P}, @var{p0})
##
## @cindex Markov chain, disctete time
## @cindex Mean time to absorption
##
## Compute the expected number of steps before absorption for the 
## DTMC with @math{N \times N} transition probability matrix @var{P}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## Transition probability matrix.
##
## @item p0
## Initial state occupancy probabilities.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item t
## When called with a single argument, @var{t} is a vector such that
## @code{@var{t}(i)} is the expected number of steps before being
## absorbed, starting from state @math{i}. When called with two
## arguments, @var{t} is a scalar and represents the average number of
## steps before absorption, given initial state occupancy probabilities
## @var{p0}.
##
## @item B
## When called with a single argument, @var{B} is a @math{N \times N}
## matrix where @code{@var{B}(i,j)} is the probability of being absorbed
## in state @math{j}, starting from state @math{i}; if @math{j} is not
## absorbing, @code{@var{B}(i,j) = 0}; if @math{i} is absorbing, then
## @code{@var{B}(i,i) = 1}. When called with two arguments, @var{B} is a
## vector with @math{N} elements where @code{@var{B}(j)} is the
## probability of being absorbed in state @var{j}, given initial state
## occupancy probabilities @var{p0}.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [t B] = dtmc_mtta( P, p0 )

  persistent epsilon = 10*eps;

  if ( nargin < 1 || nargin > 2 )
    print_usage();
  endif

  [K err] = dtmc_check_P(P);

  (K>0) || \
      usage(err);
  
  if ( nargin == 2 )
    ( isvector(p0) && length(p0) == K && all(p0>=0) && abs(sum(p0)-1.0)<epsilon ) || \
	usage( "p0 must be a probability vector" );
  endif


  ## identify transient states
  tr = find(diag(P) < 1);
  ab = find(diag(P) == 1);
  k = length(tr); # number of transient states
  if ( k == K )
    error("There are no absorbing states");
  endif

  ## Source: Grinstead, Charles M.; Snell, J. Laurie (July 1997). "Ch.
  ## 11: Markov Chains". Introduction to Probability. American
  ## Mathematical Society. ISBN 978-0821807491.

  ## http://www.cs.virginia.edu/~gfx/Courses/2006/DataDriven/bib/texsyn/Chapter11.pdf

  N = (eye(k) - P(tr,tr));
  R = P(tr,ab);

  res = N \ ones(k,1);
  t = zeros(1,rows(P));
  t(tr) = res;

  tmp = N \ R;
  B = zeros(size(P));
  B(tr,ab) = tmp;
  B(ab,ab) = 1;

  if ( nargin == 2 )
    t = dot(t,p0);
    B = p0*B;
  endif
endfunction
%!test
%! P = dtmc_bd([0 .5 .5 .5], [.5 .5 .5 0]);
%! [t B] = dtmc_mtta(P);
%! assert( t, [0 3 4 3 0], 10*eps );
%! assert( B([2 3 4],[1 5]), [3/4 1/4; 1/2 1/2; 1/4 3/4], 10*eps );
%! assert( B(1,1), 1 );
%! assert( B(5,5), 1 );

%!test
%! P = dtmc_bd([0 .5 .5 .5], [.5 .5 .5 0]);
%! [t B] = dtmc_mtta(P, [0 0 1 0 0]);
%! assert( t, 4, 10*eps );
%! assert( B(1), 0.5, 10*eps );
%! assert( B(5), 0.5, 10*eps );

## Compute the probability of completing the "snakes and ladders"
## game in n steps, for various values of n. Also, computes the expected
## number of steps which are necessary to complete the game.
## Source: 
## http://mapleta.emich.edu/aross15/coursepack3419/419/ch-04/chutes-and-ladders.pdf
%!demo
%! n = 6;
%! P = zeros(101,101);
%! ## setup transitions through the spinner
%! for j=0:(100-n)
%!   for i=1:n
%!     P(1+j,1+j+i) = 1/n;
%!   endfor
%! endfor  
%! for j=(101-n):100 
%!   P(1+j,1+j) = (n-100+j)/n;
%! endfor
%! for j=(101-n):100
%!   for i=1:(100-j)
%!     P(1+j,1+j+i) = 1/n;
%!   endfor
%! endfor
%! Pstar = P;
%! ## setup snakes and ladders
%! SL = [1 38; \
%!       4 14; \
%!       9 31; \
%!       16 6; \
%!       21 42; \
%!       28 84; \
%!       36 44; \
%!       47 26; \
%!       49 11; \
%!       51 67; \
%!       56 53; \
%!       62 19; \
%!       64 60; \
%!       71 91; \
%!       80 100; \
%!       87 24; \
%!       93 73; \
%!       95 75; \
%!       98 78 ];
%! for ii=SL;
%!   i = ii(1);
%!   j = ii(2);
%!   Pstar(1+i,:) = 0;
%!   for k=0:100
%!     if ( k != j )
%!       Pstar(1+k,1+j) = P(1+k,1+j) + P(1+k,1+i);
%!     endif
%!   endfor
%!   Pstar(:,1+i) = 0;
%! endfor
%! Pstar += diag( 1-sum(Pstar,2) );
%!
%! nsteps = 50; # number of steps
%! Pfinish = zeros(1,nsteps); # Pfinish(i) = probability of finishing after step i
%! start = zeros(1,101); start(1) = 1;
%! for i=1:nsteps
%!   pn = dtmc(Pstar,i,start);
%!   Pfinish(i) = pn(101); # state 101 is the ending (absorbing) state
%! endfor
%! f = dtmc_mtta(Pstar);
%! ## f(1) is the mean time to absorption starting from state 1
%! printf("Average number of steps to complete the game: %f\n", f(1) );
%! plot(Pfinish, ";Probability of finishing the game;");
%! xlabel("Step number");
