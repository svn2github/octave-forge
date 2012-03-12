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
##
## @cindex Markov chain, disctete time
## @cindex Mean time to absorption
##
## Compute the expected number of steps before absorption for the DTMC
## described by the transition probability matrix @var{P},
##
## @strong{INPUTS}
##
## @table @var
##
## @item P
## Transition probability matrix .
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item t
## @code{@var{t}(i)} is the expected number of steps before being absorbed,
## starting from state @math{i}.
##
## @item B
## @code{@var{B}(i,j)} is the probability of being absorbed in state
## @math{j}, starting from state @math{i}. If @math{j} is not absorbing,
## @code{@var{B}(i,j) = 0}; if @math{i} is absorbing, then
## @code{@var{B}(i,i) = 1}..
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [res B] = dtmc_mtta( P )

  persistent epsilon = 10*eps;

  if ( nargin != 1 )
    print_usage();
  endif

  [K err] = dtmc_check_P(P);

  (K>0) || \
      usage(err);

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

  t = N \ ones(k,1);
  res = zeros(1,rows(P));
  res(tr) = t;

  tmp = N \ R;
  B = zeros(size(P));
  B(tr,ab) = tmp;
  B(ab,ab) = 1;
endfunction
%!test
%! P = dtmc_bd([0 .5 .5 .5], [.5 .5 .5 0]);
%! [t B] = dtmc_mtta(P);
%! assert( t, [0 3 4 3 0], 10*eps );
%! assert( B([2 3 4],[1 5]), [3/4 1/4; 1/2 1/2; 1/4 3/4], 10*eps );
%! assert( B(1,1), 1 );
%! assert( B(5,5), 1 );

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
