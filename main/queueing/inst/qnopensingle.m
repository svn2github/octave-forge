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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopensingle (@var{lambda}, @var{S}, @var{V}) 
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopensingle (@var{lambda}, @var{S}, @var{V}, @var{m})
##
## @cindex open network, single class
## @cindex BCMP network
##
## Analyze open, single class BCMP queueing networks.
##
## This function works for a subset of BCMP single-class open networks
## satisfying the following properties:
##
## @itemize
##
## @item The allowed service disciplines at network nodes are: FCFS,
## PS, LCFS-PR, IS (infinite server);
##
## @item Service times are exponentially distributed and
## load-independent; 
##
## @item Service center @math{i} can consist of @code{@var{m}(i) @geq{} 1} 
## identical servers.
##
## @item Routing is load-independent
##
## @end itemize
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## Overall external arrival rate (@code{@var{lambda}>0}).
##
## @item S
## @code{@var{S}(k)} is the average service time at center
## @math{i} (@code{@var{S}(k)>0}).
##
## @item V
## @code{@var{V}(k)} is the average number of visits to center
## @math{k} (@code{@var{V}(k) @geq{} 0}).
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{i}. If
## @code{@var{m}(k) < 1}, then service center @math{k} is a delay center
## (IS); otherwise it is a regular queueing center with
## @code{@var{m}(k)} servers. Default is @code{@var{m}(k) = 1} for each
## @math{k}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## If @math{k} is a queueing center, 
## @code{@var{U}(k)} is the utilization of center @math{k}.
## If @math{k} is an IS node, then @code{@var{U}(k)} is the
## @emph{traffic intensity} defined as @code{@var{X}(k)*@var{S}(k)}.
##
## @item R
## @code{@var{R}(k)} is the average response time of center @math{k}.
##
## @item Q
## @code{@var{Q}(k)} is the average number of requests at center
## @math{k}.
##
## @item X
## @code{@var{X}(k)} is the throughput of center @math{k}.
##
## @end table
##
## @seealso{qnopen,qnclosed,qnvisits}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnopensingle( lambda, S, V, m )
  if ( nargin < 3 || nargin > 4 )
    print_usage();
  endif
  ( isscalar(lambda) && lambda>0 ) || \
      error( "lambda must be a positive number" );
  lambda = lambda(:)';
  ( isvector( S ) && all(S>0) ) || \
      error( "S must be a vector >0" );
  S = S(:)';
  K = length(S);
  ( isvector( V ) && length(V)==K && all(V>=0) ) || \
      error( "V must be a vector >=0 and of the same length as S" );
  V = V(:)';

  if ( nargin < 4 )
    m = ones(1,K);
  else
    (isvector(m) && (length(m) == K)) || \
	error( "m must be a vector of %d elements", K);
    m = m(:)';
    [err m] = common_size(m,S);
    ( err == 0 ) || \
        error( "m and S are not of common size" );
  endif

  ## Compute maximum processing capacity
  lambda_sat = 1 / max( S.* V );
  (lambda <= lambda_sat) || \
      error( "Processing capacity exceeded (lambda must be less than %f)", lambda_sat );

  l = lambda*V; # arrival rates

  i = find( m == 1 ); # single station queueing centers
  if numel(i)
    [U(i) R(i) Q(i) X(i)] = qnmm1( l(i), 1./S(i) );
  endif
  
  i = find( m<1 ); # delay centers
  if numel(i)
    [U(i) R(i) Q(i) X(i)] = qnmminf( l(i), 1./S(i) );
  endif
  
  i = find( m>1 ); # multiple stations queueing centers
  if numel(i)
    [U(i) R(i) Q(i) X(i)] = qnmmm( l(i), 1./S(i), m(i) );
  endif
endfunction
%!test
%! lambda = 0;
%! S = [1 1 1];
%! V = [1 1 1];
%! fail( "qnopensingle(lambda,S,V)","lambda must be");
%! lambda = 1;
%! S = [1 0 1];
%! fail( "qnopensingle(lambda,S,V)","S must be");
%! S = [1 1 1];
%! m = [1 1];
%! fail( "qnopensingle(lambda,S,V,m)","m must be a vector");
%! V = [1 1 1 1];
%! fail( "qnopensingle(lambda,S,V)","same length as S");
 
%!test
%! # Example 34.1 p. 572 Bolch et al.
%! lambda = 3;
%! V = [16 7 8];
%! S = [0.01 0.02 0.03];
%! [U R Q X] = qnopensingle( lambda, S, V );
%! assert( R, [0.0192 0.0345 0.107], 1e-2 );
%! assert( U, [0.48 0.42 0.72], 1e-2 );

%!test
%! # Example p. 113, Lazowska et al.
%! V = [121 70 50];
%! S = [0.005 0.03 0.027];
%! lambda=0.3;
%! [U R Q X] = qnopensingle( lambda, S, V );
%! assert( U(1), 0.182, 1e-3 );
%! assert( X(1), 36.3, 1e-2 );
%! assert( Q(1), 0.222, 1e-3 );

%!test
%! # Compare the results of this function with qnjackson
%! P = [ 0 0.4 0.6 0; ...
%!       0.2 0 0.2 0.6; ...
%!       0 0 0 1; ...
%!       0 0 0 0 ];
%! lambda = [0.1 0 0 0.3];
%! V = qnvisits(P,lambda);
%! S = [2 1 2 1.8];
%! m = [3 1 1 2];
%! [U R Q X] = qnopensingle( sum(lambda), S, V, m );
%! [U_j R_j Q_j X_j] = qnjackson( lambda, S, P, m );
%! assert( U, U_j, 1e-4 );
%! assert( R, R_j, 1e-4 );
%! assert( Q, Q_j, 1e-4 );
%! assert( X, X_j, 1e-4 );

%!test
%! lambda=[1];
%! P=[0];
%! V=qnvisits(P,lambda);
%! S=[0.25];
%! [U1 R1 Q1 X1]=qnopensingle(sum(lambda),S,V); 
%! [U2 R2 Q2 X2]=qnmm1(lambda(1),1/S(1));
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );
%! assert( X1, X2, 1e-5 );


%!demo
%! lambda = 3;
%! V = [16 7 8];
%! S = [0.01 0.02 0.03];
%! [U R Q X] = qnopensingle( lambda, S, V );
%! R_s = dot(R,V) # System response time
%! N = sum(Q) # Average number in system

