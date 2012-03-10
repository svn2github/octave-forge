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
## @deftypefn {Function File} {@var{L} =} ctmc_exps (@var{Q}, @var{tt}, @var{p} )
## @deftypefnx {Function File} {@var{L} =} ctmc_exps (@var{Q}, @var{p})
##
## @cindex Markov chain, continuous time
## @cindex Expected sojourn time
##
## With three arguments, compute the expected time @code{@var{L}(t,j)}
## spent in each state @math{j} during the time interval
## @code{[0,@var{tt}(t))}, assuming that at time 0 the state occupancy
## probability was @var{p}. With two arguments, compute the expected
## time @code{@var{L}(j}} spent in each state @math{j} until absorption.
##
## @strong{INPUTS}
##
## @table @var
##
## @item Q
## @math{N \times N} infinitesimal generator matrix. @code{@var{Q}(i,j)}
## is the transition rate from state @math{i} to state @math{j}, @math{1
## @leq{} i \neq j @leq{} N}. The matrix @var{Q} must also satisfy the
## condition @math{\sum_{j=1}^N Q_{ij} = 0}.
##
## @item tt
## This parameter is a vector used for numerical integration. The first
## element @code{@var{tt}(1)} must be 0, and the last element
## @code{@var{tt}(end)} must be the upper bound of the interval
## @math{[0,t)} of interest (@code{@var{tt}(end) == @math{t}}).
##
## @item p
## Initial occupancy probability vector; @code{@var{p}(i)} is the
## probability the system is in state @math{i} at time 0, @math{i = 1,
## @dots{}, N}
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item L
## If this function is called with three arguments, @var{L} is a matrix
## of size @code{[length(@var{tt}), N]} where @code{@var{L}(t,j)} is the
## expected time spent in state @math{j} during the interval
## @code{[0,@var{tt}(t)]}. If this function is called with two
## arguments, @var{L} is a vector with @math{N} elements where
## @code{@var{L}(j)} is the expected time spent in state @math{j} until
## absorption, if @math{j} is a transient state. If @math{j}
## is an absorbing state, @code{@var{L}(j) = 0}.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function L = ctmc_exps( Q, varargin )

  persistent epsilon = 10*eps;

  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif

  issquare(Q) || \
      usage( "Q must be a square matrix" );

  ( norm( sum(Q,2), "inf" ) < epsilon ) || \
      error( "Q is not an infinitesimal generator matrix" );

  if ( nargin == 2 )
    p = varargin{1};
  else
    tt = varargin{1};
    p = varargin{2};
  endif

  ( isvector(p) && length(p) == size(Q,1) && all(p>=0) && abs(sum(p)-1.0)<epsilon ) || \
      usage( "p must be a probability vector" );

  if ( nargin == 3 ) 
    ( isvector(tt) && abs(tt(1)) < epsilon ) || \
	usage( "tt must be a vector, and tt(1) must be 0.0" );
    tt = tt(:)'; # make tt a row vector
    p = p(:)'; # make p a row vector
    ff = @(x,t) (x(:)'*Q+p);
    fj = @(x,t) (Q);
    L = lsode( {ff, fj}, zeros(size(p)), tt );
  else
#{
    ## F(t) are the transient state occupancy probabilities at time t.
    ## It is known that F(t) = p*expm(Q*t) (see function ctmc()).
    ## The expected times spent in each state until absorption can
    ## be computed as the integral of F(t) from t=0 to t=inf
    F = @(t) (p*expm(Q*t)); ## FIXME: this must be restricted to transient states ONLY!!!!

    ## Since function quadv does not support infinite integration
    ## limits, we define a new function G(u) = F(tan(pi/2*u)) such that
    ## the integral of G(u) on [0,1] is the integral of F(t) on [0,
    ## +inf].
    G = @(u) (F(tan(pi/2*u))*pi/2*(1+tan(pi/2*u)**2));

    L = quadv(G,0,1);
#}
    ## Find nonzero rows. Nonzero rows correspond to transient states,
    ## while zero rows are absorbing states. If there are no zero rows,
    ## then the Markov chain does not contain absorbing states and we
    ## raise an error
    N = rows(Q);
    nzrows = find( any( abs(Q) > epsilon, 2 ) );
    if ( length( nzrows ) == N )
      error( "There are no absorbing states" );
    endif
    
    QN = Q(nzrows,nzrows);
    pN = p(nzrows);
    LN = -pN*inv(QN);
    L = zeros(1,N);
    L(nzrows) = LN;
  endif
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
%! #L2 = 0*L;
%! #for i=1:length(tt)
%! #  L2(i,:) = quadv( @(t) (p0*expm(Q*t)) , 0, tt(i) );
%! #endfor
%! plot( tt, L(:,1), ";State 1;", "linewidth", 2, \
%! #      tt, L2(:,1), "+;State 1 (quadv);", "markersize", 8, \
%!       tt, L(:,2), ";State 2;", "linewidth", 2, \
%!       tt, L(:,3), ";State 3;", "linewidth", 2, \
%!       tt, L(:,4), ";State 4 (absorbing);", "linewidth", 2);
%! legend("location","northwest");
%! xlabel("Time");
%! ylabel("Expected sojourn time");

%!demo
%! lambda = 0.5;
%! N = 4;
%! birth = lambda*linspace(1,N-1,N-1);
%! death = 0*birth;
%! Q = diag(birth,1)+diag(death,-1);
%! Q -= diag(sum(Q,2));
%! p0 = zeros(1,N); p0(1)=1;
%! L = ctmc_exps(Q,p0)
