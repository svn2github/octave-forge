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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Ql}, @var{Qu}] =} qnclosedgb (@var{N}, @var{D}, @var{Z})
##
## @cindex bounds, geometric
## @cindex closed network
##
## Compute Geometric Bounds (GB) for single-class, closed Queueing Networks.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## number of requests in the system (scalar, @code{@var{N} > 0}).
##
## @item D
## @code{@var{D}(k)} is the service demand of service center @math{k}
## (@code{@var{D}(k) @geq{} 0}).
##
## @item Z
## external delay (think time, scalar). If omitted, it is assumed to be zero.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## @itemx Xu
## Lower and upper bound on the system throughput. If @code{@var{Z}>0},
## these bounds are computed using @emph{Geometric Square-root Bounds}
## (GSB). If @code{@var{Z}==0}, these bounds are computed using @emph{Geometric Bounds} (GB)
##
## @item Ql
## @itemx Qu
## @code{@var{Ql}(i)} and @code{@var{Qu}(i)} are the lower and upper
## bounds respectively of the queue length for service center @math{i}.
##
## @end table
##
## @seealso{qnclosedab}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [X_lower X_upper Q_lower Q_upper] = qnclosedgb( N, L, Z, X_minus, X_plus )
  ## The original paper uses the symbol "L" instead of "D" to denote the
  ## loadings of service centers. In this function we adopt the same
  ## notation as the paper.
  if ( nargin < 2 || nargin > 5 )
    print_usage();
  endif
  ( isscalar(N) && N > 0 ) || \
      usage( "N must be >0" );
  ( isvector(L) && length(L) > 0 && all( L >= 0 ) ) || \
      usage( "D must be a vector >=0" );
  L = L(:)'; # make L a row vector
  if ( nargin < 3 )
    Z = 0;
  else
    ( isscalar(Z) && (Z >= 0) ) || \
        usage( "Z must be >=0" );
  endif
  L_tot = sum(L);
  L_max = max(L);
  M = length(L);
  if ( nargin < 4 ) 
    [X_minus X_plus] = qnclosedab(N,L,Z);
  endif
  ##[X_minus X_plus] = [0 1/L_max];
  [Q_lower Q_upper] = __compute_Q( N, L, Z, X_plus, X_minus);
  [Q_lower_Nm1 Q_upper_Nm1] = __compute_Q( N-1, L, Z, X_plus, X_minus);
  if ( Z > 0 )
    ## Use Geometric Square-root Bounds (GSB)
    i = find(L<L_max);
    bN = Z+L_tot+L_max*(N-1)-sum( (L_max-L(i)).*Q_lower_Nm1(i) );
    X_lower = 2*N/(bN+sqrt(bN^2-4*Z*L_max*(N-1)));
    bN = Z+L_tot+L_max*(N-1)-sum( (L_max-L(i)).*Q_upper_Nm1(i) );
    X_upper = 2*N/(bN+sqrt(bN^2-4*Z*L_max*N));
  else
    ## Use Geometric Bounds (GB). FIXME: given that this branch is
    ## executed when Z=0, the expressions below can be simplified.
    X_lower = N/(Z+L_tot+L_max*(N-1-Z*X_minus) - ...
                 sum( (L_max - L) .* Q_lower_Nm1 ) );
    X_upper = N/(Z+L_tot+L_max*(N-1-Z*X_plus) - ...
                 sum( (L_max - L) .* Q_upper_Nm1 ) );
  endif
endfunction

## [ Q_lower Q_uppwer ] = __compute_Q( N, D, Z, X_plus, X_minus )
##
## compute Q_lower(i) and Q_upper(i), the lower and upper bounds
## respectively for queue length at service center i, for a closed
## network with N customers, service demands D and think time Z. This
## function uses Eq. (8) and (13) from the reference paper.
function [ Q_lower Q_upper ] = __compute_Q( N, L, Z, X_plus, X_minus )
  isscalar(X_plus) || usage( "X_plus must be a scalar" );
  isscalar(X_minus) || usage( "X_minus must be a scalar" );
  ( isscalar(N) && (N>=0) ) || usage( "N is not valid" );
  L_tot = sum(L);
  L_max = max(L);
  M = length(L);
  m_max = sum( L == L_max );
  y = Y = zeros(1,M);
  ## first, handle the case of servers with loading less than the
  ## maximum that is, L(i) < L_max
  i=find(L<L_max);
  y(i) = L(i)*N./(Z+L_tot+L_max*N);
  Q_lower(i) = y(i)./(1-y(i)) .- (y(i).^(N+1))./(1-y(i)); # Eq. (8)
  Y(i) = L(i)*X_plus;
  Q_upper(i) = Y(i)./(1-Y(i)) .- (Y(i).^(N+1))./(1-Y(i)); # Eq. (13)
  ## now, handle the case of servers with demand equal to the maximum
  i=find(L==L_max);
  Q_lower(i) = 1/m_max*(N-Z*X_plus - sum( Q_upper( find(L<L_max) ) ) ); \
				# Eq. (8)
      Q_upper(i) = 1/m_max*(N-Z*X_minus - sum( Q_lower( find(L<L_max) \
						       ) ) ); # Eq. (13)
endfunction

%!test
%! fail( "qnclosedpb( 1, [] )", "vector" );
%! fail( "qnclosedpb( 1, [0 -1])", "vector" );
%! fail( "qnclosedpb( 0, [1 2] )", "positive integer" );
%! fail( "qnclosedpb( -1, [1 2])", "positive integer" );

%!# shared test function
%!function test_gb( D, expected, Z=0 )
%! for i=1:rows(expected)
%!   N = expected(i,1);
%!   [X_lower X_upper Q_lower Q_upper] = qnclosedgb(N,D,Z);
%!   X_exp_lower = expected(i,2);
%!   X_exp_upper = expected(i,3);
%!   assert( [N X_lower X_upper], [N X_exp_lower X_exp_upper], 1e-4 )
%! endfor

%!xtest
%! # table IV
%! D = [ 0.1 0.1 0.09 0.08 ];
%! #            N  X_lower  X_upper
%! expected = [ 2  4.3040   4.3174; ...
%!              5  6.6859   6.7524; ...
%!              10 8.1521   8.2690; ...
%!              20 9.0947   9.2431; ...
%!              80 9.8233   9.8765 ];
%! test_gb(D, expected);

%!xtest
%! # table V
%! D = [ 0.1 0.1 0.09 0.08 ];
%! Z = 1;
%! #            N  X_lower  X_upper
%! expected = [ 2  1.4319   1.5195; ...
%!              5  3.3432   3.5582; ...
%!              10 5.7569   6.1410; ...
%!              20 8.0856   8.6467; ...
%!              80 9.7147   9.8594];
%! test_gb(D, expected, Z);

%!test
%! P = [0 0.3 0.7; 1 0 0; 1 0 0];
%! S = [1 0.6 0.2];
%! m = ones(1,3);
%! V = qnvisits(P);
%! Nmax = 20;
%!
%! ## Test case with Z>0
%! for n=1:Nmax
%!   [X_gb_lower X_gb_upper Q_gb_lower Q_gb_upper] = qnclosedgb(n, S.*V, 2);
%!   [U R Q X] = qnclosed( n, S, V, m, 2 );
%!   X_mva = X(1)/V(1);
%!   assert( X_gb_lower <= X_mva );
%!   assert( X_gb_upper >= X_mva );
%!   assert( Q_gb_lower <= Q+1e-5 ); # compensate for numerical errors
%!   assert( Q_gb_upper >= Q-1e-5 ); # compensate for numerical errors
%! endfor

%!test
%! P = [0 0.3 0.7; 1 0 0; 1 0 0];
%! S = [1 0.6 0.2];
%! m = ones(1,3);
%! V = qnvisits(P);
%! Nmax = 20;
%!
%! ## Test case with Z=0
%! for n=1:Nmax
%!   [X_gb_lower X_gb_upper Q_gb_lower Q_gb_upper] = qnclosedgb(n, S.*V, 0);
%!   [U R Q X] = qnclosed( n, S, V, m, 0 );
%!   X_mva = X(1)/V(1);
%!   assert( X_gb_lower <= X_mva );
%!   assert( X_gb_upper >= X_mva );
%!   assert( Q_gb_lower <= Q );
%!   assert( Q_gb_upper >= Q );
%! endfor
