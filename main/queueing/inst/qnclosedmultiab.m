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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultiab (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultiab (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultiab (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultiab (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
##
## @cindex bounds, asymptotic
## @cindex closed network
## @cindex multiclass network, closed
##
## Compute Asymptotic Bounds for multiclass networks.
## Single-server and infinite-server nodes are supported.
## Multiple-server nodes and general load-dependent servers are not
## supported.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## @code{@var{N}(c)} is the number of class @math{c} requests in the system.
##
## @item D
## @code{@var{D}(c, k)} is class @math{c} service demand
## at center @math{k} (@code{@var{D}(c,k) @geq{} 0}).
##
## @item S
## @code{@var{S}(c, k)} is the mean service time of class @math{c}
## requests at center @math{k} (@code{@var{S}(c,k) @geq{} 0}).
##
## @item V
## @code{@var{V}(c,k)} is the average number of visits of class @math{c}
## requests to center @math{k} (@code{@var{V}(c,k) @geq{} 0}).
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}
## (if @var{m} is a scalar, all centers have that number of servers). If
## @code{@var{m}(k) < 1}, center @math{k} is a delay center (IS);
## if @code{@var{m}(k) = 1}, center @math{k} is a M/M/1-FCFS server.
## This function does not support multiple-server nodes. Default
## is 1.
##
## @item Z
## @code{@var{Z}(c)} is class @math{c} external delay
## (@code{@var{Z}(c) @geq{} 0}). Default is 0.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## @itemx Xu
## Lower and upper class @math{c} throughput bounds.
##
## @item Rl
## @itemx Ru
## Lower and upper class @math{c} response time bounds.
##
## @end table
##
## @seealso{qnclosedsingleab}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnclosedmultiab( N, S, V, m, Z )

  if ( nargin<2 || nargin>5 )
    print_usage();
  endif

  ( isvector(N) && length(N)>0 ) || \
      error("N must be a nonempty vector");
  all(N >= 0) || \
      error( "N must contain nonnegative values" );
  sum(N)>0 || \
      error( "The network has no requests" );
  N = N(:)';

  C = length(N); # number of classes

  ( ismatrix(S) && rows(S) == C ) || \
      error("S/D must be a matrix with %d rows", C);
  all(all(S>=0)) || \
      error("S/D must contain nonnegative values");

  K = columns(S);

  if ( nargin<3 )
    V = ones(size(S));
  else
    (ismatrix(V) && size_equal(S,V) ) || \
	error("V must be a %d x %d matrix", C, K);
    all(all(V>=0)) || \
	error("V must contain nonnegative values");
  endif

  if ( nargin<4 )
    m = ones(1,K);
  else
    (isvector(m) && length(m) == K ) || \
	error("m must be a vector with %d elements", K);
    all(m<=1) || \
	error("Multiple-server nodes are not supported");
    m = m(:)';
  endif

  if (nargin<5)
    Z = zeros(1,C);
  else
    (isvector(Z) && length(Z) == C ) || \
	error("Z must be a vector with %d elements", C);
    all(Z>=0) || \
	error("Z must contain nonnegative values");
    Z = Z(:)';
  endif

  D = S .* V;

  Dc_single = sum(D(:,(m==1)),2)'; # class c demand on single-server nodes
  Dc_delay = sum(D(:,(m<1)),2)'; # class c demand on delay centers
  Dc = sum(D,2)'; # class c total demand
  Dcmax = max(D,[],2)'; # maximum class c demand at any server
  Xl = N ./ ( dot(N,Dc_single) .+ Dc_delay .+ Z);
  Xu = min( 1./Dcmax, N ./ (Dc .+ Z) );
  Rl = Ru = [];
endfunction

%!test
%! fail("qnclosedmultiab([],[])", "nonempty");
%! fail("qnclosedmultiab([0 0], [1 2])", "no requests");
%! fail("qnclosedmultiab([1 0], [1 2 3])", "2 rows");
%! fail("qnclosedmultiab([1 0], [1 2 3; 4 5 -1])", "nonnegative");
%! fail("qnclosedmultiab([1 2], [1 2 3; 4 5 6], [1 2 3])", "2 x 3");
%! fail("qnclosedmultiab([1 2], [1 2 3; 4 5 6], [1 2 3; 4 5 -1])", "nonnegative");
%! fail("qnclosedmultiab([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1])", "3 elements");
%! fail("qnclosedmultiab([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 2])", "not supported");
%! fail("qnclosedmultiab([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 -1],[1 2 3])", "2 elements");
%! fail("qnclosedmultiab([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 -1],[1 -2])", "nonnegative");

%!demo
%! S = [10 7 5 4; \
%!      5  2 4 6];
%! NN=20;
%! Xl = Xu = Xmva = zeros(NN,2);
%! for n=1:NN
%!   N=[n,10];
%!   [a b] = qnclosedmultiab(N,S);
%!   Xl(n,:) = a; Xu(n,:) = b;
%!   [U R Q X] = qnclosedmultimva(N,S,ones(size(S)));
%!   Xmva(n,:) = X(:,1)';
%! endfor
%! subplot(2,1,1);
%! plot(1:NN,Xl(:,1),"linewidth", 2, 1:NN,Xu(:,1),"linewidth", 2, \
%!      1:NN,Xmva(:,1),";MVA;");
%! title("Class 1 throughput");
%! subplot(2,1,2);
%! plot(1:NN,Xl(:,2),"linewidth", 2, 1:NN,Xu(:,2), "linewidth", 2,\
%!      1:NN,Xmva(:,2),";MVA;");
%! title("Class 2 throughput");
%! xlabel("Number of class 1 requests");


