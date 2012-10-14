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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopenmulti (@var{lambda}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopenmulti (@var{lambda}, @var{S}, @var{V}, @var{m})
##
## @cindex open network, multiple classes
## @cindex multiclass network, open
##
## Exact analysis of open, multiple-class BCMP networks. The network can
## be made of @emph{single-server} queueing centers (FCFS, LCFS-PR or
## PS) or delay centers (IS). This function assumes a network with
## @math{K} service centers and @math{C} customer classes.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## @code{@var{lambda}(c)} is the external
## arrival rate of class @math{c} customers (@code{@var{lambda}(c)>0}).
##
## @item S
## @code{@var{S}(c,k)} is the mean service time of class @math{c}
## customers on the service center @math{k} (@code{@var{S}(c,k)>0}).
## For FCFS nodes, average service times must be class-independent.
##
## @item V
## @code{@var{V}(c,k)} is the average number of visits of class @math{c}
## customers to service center @math{k} (@code{@var{V}(c,k) @geq{} 0 }).
##
## @item m
## @code{@var{m}(k)} is the number of servers at service center
## @math{k}. Valid values are @code{@var{m}(k) < 1} to denote a delay
## center (@math{-/G/\infty}), and @code{@var{m}(k)==1} to denote
## a single server queueing center (@math{M/M/1}--FCFS,
## @math{-/G/1}--LCFS-PR or @math{-/G/1}--PS).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## If @math{k} is a queueing center, then @code{@var{U}(c,k)} is the
## class @math{c} utilization of center @math{k}. If @math{k} is
## an IS node, then @code{@var{U}(c,k)} is the 
## class @math{c} @emph{traffic intensity}
## defined as @code{@var{X}(c,k)*@var{S}(c,k)}.
##
## @item R
## @code{@var{R}(c,k)} is the class @math{c} response time at
## center @math{k}. The system response time for
## class @math{c} requests can be computed
## as @code{dot(@var{R}, @var{V}, 2)}.
##
## @item Q
## @code{@var{Q}(c,k)} is the average number of class @math{c} requests
## at center @math{k}. The average number of class @math{c} requests
## in the system @var{Qc} can be computed as @code{Qc = sum(@var{Q}, 2)}
##
## @item X
## @code{@var{X}(c,k)} is the class @math{c} throughput
## at center @math{k}.
##
## @end table
##
## @seealso{qnopen,qnopensingle,qnvisits}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/
function [U R Q X] = qnopenmulti( lambda, S, V, m )
  if ( nargin < 3 || nargin > 4 )
    print_usage();
  endif
  isvector(lambda) && all(lambda > 0) || \
      error( "lambda must be a vector of positive floats" );
  lambda = lambda(:)'; # make lambda a row vector
  C = length(lambda);
  K = columns(S);
  [C,K] == size(S) || \
      error( "rows(S) must be equal to length(lambda)" );
  all(all( S > 0 )) || \
      error( "S(c,k) must be > 0" );
  [C,K] == size(V) || \
      error( "V must be a matrix of the same size as S" );
  all( all(V>= 0) ) || \
      error( "V must be >= 0 " );

  if ( nargin < 4 )
    m = ones(1,K);
  else
    ( isvector( m ) && length(m) == K && all( m <= 1 ) ) || \
        error( "m must be less than or equal to ones(1,K)" );
    m = m(:)'; # make m a row vector
  endif

  D = S .* V; # Service demands: D(c,k) = S(c,k) * V(c,k)
  max(lambda * D) < 1 || \
      error( "processing capacity exceeded" );

  U = R = Q = X = zeros(C,K);
  i_delay  = find(m<1);
  i_single = find(m==1);
  U = diag(lambda)*D; # U(c,:) = lambda(c)*D(c,:);
  X = diag(lambda)*V; # X(c,:) = lambda(c)*V(c,:);
  
  ## delay centers
  R(:,i_delay) = S(:,i_delay);
  Q(:,i_delay) = U(:,i_delay);

  ## Queueing centers
  for c=1:C
    R(c,i_single) = S(c,i_single) ./ ( 1 - sum(U(:,i_single),1) );
    Q(c,i_single) = U(c,i_single) ./ ( 1 - sum(U(:,i_single),1) );
  endfor
endfunction
%!test
%! V = [1 1; 1 1];
%! S = [1 3; 2 4];
%! lambda = [3/19 2/19];
%! [U R Q] = qnopenmulti(lambda, S, V);
%! assert( U(1,1), 3/19, 1e-6 );
%! assert( U(2,1), 4/19, 1e-6 );
%! assert( R(1,1), 19/12, 1e-6 );
%! assert( R(1,2), 57/2, 1e-6 );
%! assert( Q(1,1), .25, 1e-6 );

%!test
%! # example p. 138 Zahorjan et al.
%! V = [ 10 9; 5 4];
%! S = [ 1/10 1/3; 2/5 1];
%! lambda = [3/19 2/19];
%! [U R Q X] = qnopenmulti(lambda, S, V);
%! assert( X(1,1), 1.58, 1e-2 );
%! assert( U(1,1), .158, 1e-3 );
%! assert( R(1,1), .158, 1e-3 ); # modified from the original example, as the reference above considers R as the residence time, not the response time
%! assert( Q(1,1), .25, 1e-2 );

