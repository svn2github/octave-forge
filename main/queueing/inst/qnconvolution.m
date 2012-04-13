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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{G}] =} qnconvolution (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}, @var{G}] =} qnconvolution (@var{N}, @var{S}, @var{V}, @var{m})
##
## @cindex closed network
## @cindex normalization constant
## @cindex convolution algorithm
##
## This function implements the @emph{convolution algorithm} for
## computing steady-state performance measures of product-form,
## single-class closed queueing networks. Load-independent service
## centers, multiple servers (@math{M/M/m} queues) and IS nodes are
## supported. For general load-dependent service centers, use the
## @code{qnconvolutionld} function instead.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## Number of requests in the system (@code{@var{N}>0}).
##
## @item S
## @code{@var{S}(k)} is the average service time on center @math{k}
## (@code{@var{S}(k) @geq{} 0}).
##
## @item V
## @code{@var{V}(k)} is the visit count of service center @math{k}
## (@code{@var{V}(k) @geq{} 0}).
##
## @item m
## @code{@var{m}(k)} is the number of servers at center
## @math{k}. If @code{@var{m}(k) < 1}, center @math{k} is a delay center (IS);
## if @code{@var{m}(k) @geq{} 1}, center @math{k}
## it is a regular @math{M/M/m} queueing center with @code{@var{m}(k)}
## identical servers. Default is @code{@var{m}(k) = 1} for all @math{k}.
##
## @end table
##
## @strong{OUTPUT}
##
## @table @var
##
## @item U
## @code{@var{U}(k)} is the utilization of center @math{k}. 
## For IS nodes, @code{@var{U}(k)} is the @emph{traffic intensity}.
##
## @item R
## @code{@var{R}(k)} is the average response time of center @math{k}.
##
## @item Q
## @code{@var{Q}(k)} is the average number of customers at center
## @math{k}.
##
## @item X
## @code{@var{X}(k)} is the throughput of center @math{k}.
##
## @item G
## Vector of normalization constants. @code{@var{G}(n+1)} contains the value of
## the normalization constant with @math{n} requests
## @math{G(n)}, @math{n=0, @dots{}, N}.
##
## @end table
##
## @seealso{qnconvolutionld}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X G] = qnconvolution( N, S, V, m )

  if ( nargin < 3 || nargin > 4 )
    print_usage();
  endif

  ( isscalar(N) && N>0 ) || \
      error( "K must be a positive scalar" );
  K = N; # To be compliant with the reference, we use K to denote the population size
  ( isvector(S) && all(S >= 0) ) || \
      error( "S must be a vector of positive scalars" );
  S = S(:)'; # make S a row vector
  N = length(S); # Number of service centers
  ( isvector(V) && size_equal(V,S) ) || \
      error( "V must be a vector of the same length as S" );
  V = V(:)';

  if ( nargin < 4 )
    m = ones(1,N);
  else
    isvector(m) || \
	error( "m must be a vector" );
    m = m(:)';
    [err m S] = common_size(m, S);
    (err == 0) || \
        error( "m and S have incompatible size" );
  endif

  ## First, we remember the indexes of IS nodes
  i_delay = find(m<1);

  m( i_delay ) = K; # IS nodes are handled as if they were M/M/K nodes with number of servers equal to the population size K, such that queueing never occurs.

  ## Initialization
  G_n = G_nm1 = zeros(1,K+1); G_n(1) = 1;
  F_n = zeros(N,K+1); F_n(:,1) = 1;
  k=0:K; G_nm1(k+1) = F_n(1,k+1) = F(1,k,V,S,m);
  ## Main convolution loop
  for n=2:N
    k=1:K; F_n(n,1+k) = F(n,k,V,S,m);
    G_n = conv( F_n(n,:), G_nm1(:) )(1:K+1);
    G_nm1 = G_n;
  endfor
  ## Done computation of G(n,k).
  G = G_n;
  G = G(:)'; # ensure G is a row vector
  ## Computes performance measures
  X = V*G(K)/G(K+1);
  U = X .* S ./ m;
  ## Adjust utilization of delay centers
  U(i_delay) = X(i_delay) .* S(i_delay);
  Q = zeros(1,N);
  i_multi = find(m>1);
  for i=i_multi
    G_N_i = zeros(1,K+1);
    G_N_i(1) = 1;
    for k=1:K
      j=1:k;
      G_N_i(k+1) = G(k+1)-dot( F_n(i,j+1), G_N_i(k-j+1) );
    endfor
    k=0:K;
    p_i(k+1) = F_n(i,k+1)./G(K+1).*G_N_i(K-k+1);
    Q(i) = dot( k, p_i( k+1 ) );
  endfor
  i_single = find(m==1);
  for i=i_single
    k=1:K;
    Q(i) = sum( ( V(i)*S(i) ) .^ k .* G(K+1-k)/G(K+1) );
  endfor
  R = Q ./ X;
endfunction

%!test
%! # Example 8.1 p. 318 Bolch et al.
%! K=3;
%! S = [ 1/0.8 1/0.6 1/0.4 ];
%! m = [2 3 1];
%! V = [ 1 .667 .2 ];
%! [U R Q X G] = qnconvolution( K, S, V, m );
%! assert( G, [1 2.861 4.218 4.465], 5e-3 );
%! assert( X, [0.945 0.630 0.189], 1e-3 );
%! assert( U, [0.590 0.350 0.473], 1e-3 );
%! assert( Q, [1.290 1.050 0.660], 1e-3 );
%! assert( R, [1.366 1.667 3.496], 1e-3 );

%!test
%! # Example 8.3 p. 331 Bolch et al.
%! # compare results of convolution to those of mva
%! S = [ 0.02 0.2 0.4 0.6 ];
%! K = 6;
%! V = [ 1 0.4 0.2 0.1 ];
%! [U_mva R_mva Q_mva X_mva G_mva] = qnclosedsinglemva(K, S, V);
%! [U_con R_con Q_con X_con G_con] = qnconvolution(K, S, V);
%! assert( U_mva, U_con, 1e-5 );
%! assert( R_mva, R_con, 1e-5 );
%! assert( Q_mva, Q_con, 1e-5 );
%! assert( X_mva, X_con, 1e-5 );
%! assert( G_mva, G_con, 1e-5 );

%!test
%! # Compare the results of convolution to those of mva
%! S = [ 0.02 0.2 0.4 0.6 ];
%! K = 6;
%! V = [ 1 0.4 0.2 0.1 ];
%! m = [ 1 -1 2 1 ]; # center 2 is IS
%! [U_mva R_mva Q_mva X_mva] = qnclosedsinglemva(K, S, V, m);
%! [U_con R_con Q_con X_con G] = qnconvolution(K, S, V, m );
%! assert( U_mva, U_con, 1e-5 );
%! assert( R_mva, R_con, 1e-5 );
%! assert( Q_mva, Q_con, 1e-5 );
%! assert( X_mva, X_con, 1e-5 );

## result = F(i,j,v,S,m)
##
## Helper fuction to compute F(i,j) as defined in Eq 7.61 p. 289 of
## Bolch, Greiner, de Meer, Trivedi "Queueing Networks and Markov
## Chains: Modeling and Performance Evaluation with Computer Science
## Applications", Wiley, 1998. This function has been vectorized,
## and accepts a vector as parameter j.
function result = F(i,j,v,S,m)
  isscalar(i) || \
      error( "i must be a scalar" );
  k_i = j;
  if ( m(i) == 1 )
    result = ( v(i)*S(i) ).^k_i;
  else
    ii = find(k_i<=m(i)); ## if k_i<=m(i)
    result(ii) = ( v(i)*S(i) ).^k_i(ii) ./ factorial(k_i(ii));
    ii = find(k_i>m(i)); ## if k_i>m(i)
    result(ii) = ( v(i)*S(i) ).^k_i(ii) ./ ( factorial(m(i))*m(i).^(k_i(ii)-m(i)) );
  endif
endfunction

%!demo
%! k = [1 2 0];
%! K = sum(k); # Total population size
%! S = [ 1/0.8 1/0.6 1/0.4 ];
%! m = [ 2 3 1 ];
%! V = [ 1 .667 .2 ];
%! [U R Q X G] = qnconvolution( K, S, V, m );
%! p = [0 0 0]; # initialize p
%! # Compute the probability to have k(i) jobs at service center i
%! for i=1:3
%!   p(i) = (V(i)*S(i))^k(i) / G(K+1) * \
%!          (G(K-k(i)+1) - V(i)*S(i)*G(K-k(i)) );
%!   printf("k(%d)=%d prob=%f\n", i, k(i), p(i) );
%! endfor
