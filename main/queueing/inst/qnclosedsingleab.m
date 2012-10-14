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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedsingleab (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedsingleab (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedsingleab (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedsingleab (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
##
## @cindex bounds, asymptotic
## @cindex closed network, single class
##
## Compute Asymptotic Bounds for throughput and response time of closed,
## single-class networks.
##
## Single-server and infinite-server nodes are supported.
## Multiple-server nodes and general load-dependent servers are not
## supported.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## number of requests in the system (scalar, @code{@var{N}>0}).
##
## @item D
## @code{@var{D}(k)} is the service demand at center @math{k}
## (@code{@var{D}(k) @geq{} 0}).
##
## @item S
## @code{@var{S}(k)} is the mean service time at center @math{k}
## (@code{@var{S}(k) @geq{} 0}).
##
## @item V
## @code{@var{V}(k)} is the average number of visits to center
## @math{k} (@code{@var{V}(k) @geq{} 0}).
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
## External delay (@code{@var{Z} @geq{} 0}). Default is 0.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## @itemx Xu
## Lower and upper system throughput bounds.
##
## @item Rl
## @itemx Ru
## Lower and upper response time bounds.
##
## @end table
##
## @seealso{qnclosedmultiab}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnclosedsingleab( N, S, V, m, Z )
  
  if (nargin<2 || nargin>5)
    print_usage();
  endif

  ( isscalar(N) && N > 0 ) || \
      error( "N must be a positive integer" );
  (isvector(S) && length(S)>0) || \
      error( "S/D must be a nonempty vector" );
  all(S>=0) || \
      error( "S/D must contain nonnegative values");
  S = S(:)';
  K = length(S);
  if ( nargin < 3 )
    V = ones(1,K);
  else
    (isvector(V) && length(V) == K) || \
	error( "V must be a vector with %d elements", K );
    all(V>=0) || \
	error( "V must contain nonnegative values" );
    V = V(:)';
  endif
  if ( nargin < 4 )
    m = ones(1,K);
  else
    (isvector(m) && length(m) == K) || \
	error( "m must be a vector with %d elements", K );
    all(m<=1) || \
	error( "multiple server nodes are not supported" );
    m = m(:)';
  endif
  if ( nargin < 5 )
    Z = 0;
  else
    ( isscalar(Z) && Z >= 0 ) || \
        error( "Z must be a nonnegative scalar" );
  endif

  D = S.*V;

  Dtot_single = sum(D(m==1)); # total demand at single-server nodes
  Dtot_delay = sum(D(m<1)); # total demand at IS nodes
  Dtot = sum(D); # total demand
  Dmax = max(D); # max demand

  Xl = N/(N*Dtot_single + Dtot_delay + Z);
  Xu = min( N/(Dtot+Z), 1/Dmax );
  Rl = max( Dtot, N*Dmax - Z );
  Ru = N*Dtot_single + Dtot_delay;
endfunction

%!test
%! fail("qnclosedsingleab(-1,0)", "N must be");
%! fail("qnclosedsingleab(1,[])", "nonempty");
%! fail("qnclosedsingleab(1,[-1 2])", "nonnegative");
%! fail("qnclosedsingleab(1,[1 2],[1 2 3])", "2 elements");
%! fail("qnclosedsingleab(1,[1 2 3],[1 2 -1])", "nonnegative");
%! fail("qnclosedsingleab(1,[1 2 3],[1 2 3],[1 2])", "3 elements");
%! fail("qnclosedsingleab(1,[1 2 3],[1 2 3],[1 2 1])", "not supported");
%! fail("qnclosedsingleab(1,[1 2 3],[1 2 3],[1 1 1],-1)", "nonnegative");
%! fail("qnclosedsingleab(1,[1 2 3],[1 2 3],[1 1 1],[0 0])", "scalar");

## Example 9.6 p. 913 Bolch et al.
%!test
%! N = 20;
%! S = [ 4.6*2 8 ];
%! Z = 120;
%! [X_l X_u R_l R_u] = qnclosedsingleab(N, S, ones(size(S)), ones(size(S)), Z);
%! assert( [X_u R_l], [0.109 64], 1e-3 );

