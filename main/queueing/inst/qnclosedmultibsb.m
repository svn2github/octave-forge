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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultibsb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultibsb (@var{N}, @var{D}, @var{Z})
##
## Compute Balanced System Bounds for multiclass networks.
## Only single-server nodes are supported.
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
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}
## (if @var{m} is a scalar, all centers have that number of servers). If
## @code{@var{m}(k) < 1}, center @math{k} is a delay center (IS);
## if @code{@var{m}(k) = 1}, center @math{k} is a M/M/1-FCFS server.
## This function does not support multiple-server nodes. Default
## is 1.
##
## @item Z
## @code{@var{Z}(c)} is class @math{c} external delay.
## Currently this function only supports 
## @code{@var{Z}(c) = 0}). Default 0.
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
## @seealso{qnclosedsinglebsb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnclosedmultibsb( N, S, V, m, Z )

  if ( nargin < 2 || nargin > 5 )
    print_usage();
  endif
  ( isvector(N) && all(N>0) ) || \
      error( "N must be a vector > 0" );
  N = N(:)'; # make N a row vector
  C = length(N);
  ( ismatrix(S) && rows(S) == length(N) && all(all(S>=0)) ) || \
      error( "wrong S size" );
  K = columns(S);
  if ( nargin < 3 )
    V = ones(size(S));
  endif   
  if ( nargin < 4 )
    m = ones(1,K);
  else
    (isvector(m) && length(m) == K) || \
	error("m must be a vector with %d elements",K);
    all(m==1) || \
	error("this function supports M/M/1-FCFS servers only");
    m = m(:)';
  endif
  if ( nargin < 5 )
    Z = 0*N;
  else
    ( isvector(Z) && all(Z == 0) && length(Z) == C ) || \
        error( "This function only supports Z == 0" );
    Z = Z(:)';
  endif

  D = S .* V;

  Dc = sum(D,2)';
  D_max = max(D,[],2)';
  D_min = min(D,[],2)';
  Xl = N ./ (Dc .+ (sum(N)-1) .* D_max);
  Xu = min( 1./D_max, N ./ ((K+sum(N)-1) .* D_min));
  Rl = N ./ Xu;
  Rl = NaN;
  Ru = N ./ Xl;
endfunction
