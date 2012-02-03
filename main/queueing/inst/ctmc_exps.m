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
## @deftypefn {Function File} {@var{L} =} ctmc_exps (@var{Q}, @var{tt}, @var{p})
##
## @cindex Markov chain, continuous time
## @cindex Expected sojourn time
##
## Compute the expected total time @code{@var{L}(t,j)} spent in state
## @math{j} during the time interval @code{[0,@var{tt}(t))}, assuming
## that at time 0 the state occupancy probability was @var{p}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item Q
## Infinitesimal generator matrix. @code{@var{Q}(i,j)} is the transition
## rate from state @math{i} to state @math{j},
## @math{1 @leq{} i \neq j @leq{} N}. The matrix @var{Q} must also satisfy the
## condition @code{sum(@var{Q},2) == 0}
##
## @item tt
## This parameter is a vector used for numerical integration. The first
## element @code{@var{tt}(1)} must be 0, and the last element
## @code{@var{tt}(end)} must be the upper bound of the interval
## @math{[0,t)} of interest (@code{@var{tt}(end) == @math{t}}).
##
## @item p
## @code{@var{p}(i)} is the probability that at time 0 the system was in
## state @math{i}, for all @math{i = 1, @dots{}, N}
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item L
## @code{@var{L}(t,j)} is the expected time spent in state @math{j}
## during the interval @code{[0,@var{tt}(t))}. @code{1 @leq{} @var{t} @leq{} length(@var{tt})}
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function L = ctmc_exps( Q, tt, p )

  persistent epsilon = 10*eps;

  if ( nargin != 3 )
    print_usage();
  endif

  issquare(Q) || \
      usage( "Q must be a square matrix" );

  ( norm( sum(Q,2), "inf" ) < epsilon ) || \
      error( "Q is not an infinitesimal generator matrix" );

  ( isvector(p) && length(p) == size(Q,1) && all(p>=0) && abs(sum(p)-1.0)<epsilon ) || \
      usage( "p must be a probability vector" );

  ( isvector(tt) && abs(tt(1)) < epsilon ) || \
      usage( "tt must be a vector, and tt(1) must be 0.0" );
  tt = tt(:)'; # make tt a row vector
  p = p(:)'; # make p a row vector
  ff = @(x,t) (x(:)'*Q+p);
  fj = @(x,t) (Q);
  L = lsode( {ff, fj}, p, tt );
endfunction

%!demo
%! lambda = 0.5;
%! N = 4;
%! birth = lambda*linspace(1,N-1,N-1);
%! death = zeros(1,N-1);
%! Q = diag(birth,1)+diag(death,-1);
%! Q -= diag(sum(Q,2));
%! tt = linspace(0,10,100);
%! p0 = zeros(1,N); p0(1)=1;
%! L = ctmc_exps(Q,tt,p0);
%! plot( tt, L(:,1), ";State 1;", "linewidth", 2, \
%!       tt, L(:,2), ";State 2;", "linewidth", 2, \
%!       tt, L(:,3), ";State 3;", "linewidth", 2, \
%!       tt, L(:,4), ";State 4 (absorbing);", "linewidth", 2);
%! legend("location","northwest");
%! xlabel("Time");
%! ylabel("Expected sojourn time");
