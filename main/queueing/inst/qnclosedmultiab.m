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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultiab (@var{N}, @var{S})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultiab (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultiab (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultiab (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
##
## @cindex bounds, asymptotic
## @cindex closed network
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
## @item S
## @code{@var{S}(c, k)} is the mean service time of class @math{c}
## requests at center @math{k}
## (@code{@var{S}(c,k) @geq{} 0}).
##
## @item V
## @code{@var{V}(c,k)} is the average number of visits of class @math{c}
## requests to center
## @math{k} (@code{@var{V}(c,k) @geq{} 0}). Default is 1.
##
## @item Z
## @code{@var{Z}(c)} is class @math{c} external delay
## (@code{@var{Z}(c) @geq{} 0}). Default is 0.
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}
## (if @var{m} is a scalar, all centers have that number of servers). If
## @code{@var{m}(k) < 1}, center @math{k} is a delay center (IS);
## if @code{@var{m}(k) = 1}, center @math{k} is a M/M/1-FCFS server.
## This function does not support multiple-server nodes. Default
## is 1.
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

  ( isvector(N) && all(N >= 0) ) || \
      error( "N must be a positive integer" );
  N = N(:)';
  sum(N)>0 || \
      error( "The network has no requests" );

  C = length(N); # number of classes

  ( ismatrix(S) && rows(S) == C && all(all(S>=0))) || \
      error("S must be a matrix >=0 with %d rows", C);
  
  K = columns(S);

  if ( nargin<3 )
    V = ones(size(S));
  else
    (ismatrix(V) && size_equal(S,V) && all(all(V>=0))) || \
	error("V must be a %d x %d matrix >=0", C, K);
  endif

  if ( nargin<4 )
    m = ones(1,K);
  else
    (isvector(m) && length(m) == K && all(m<=1)) || \
	error("m must be a vector with %d elements <=1", K);
    m = m(:)';
  endif

  if (nargin<5)
    Z = zeros(1,C);
  else
    (isvector(Z) && length(Z) == C && all(Z>=0) ) || \
	error("Z must be a vector >=0 with %d elements", C);
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
