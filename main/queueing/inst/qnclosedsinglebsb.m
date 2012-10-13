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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedsinglebsb (@var{N}, @var{S})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedsinglebsb (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedsinglebsb (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedsinglebsb (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
##
## @cindex bounds, balanced system
## @cindex closed network
##
## Compute Balanced System Bounds for single-class, closed Queueing Networks
## with @math{K} service centers.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## number of requests in the system (scalar).
##
## @item S
## @code{@var{S}(k)} is the mean service time at center @math{k}
## (@code{@var{S}(k) @geq{} 0}).
##
## @item V
## @code{@var{V}(k)} is the average number of visits to center
## @math{k} (@code{@var{V}(k) @geq{} 0}). Default is 1.
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}.
## Currently this function supports @code{@var{m}(k) = 1} only
## (sing-eserver FCFS nodes). Default is 1.
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
## Lower and upper bound on the system throughput.
##
## @item Rl
## @itemx Ru
## Lower and upper bound on the system response time.
##
## @end table
##
## @seealso{qnclosedab, qnclosedgb, qnclosedpb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnclosedsinglebsb( N, S, V, m, Z )

  if (nargin<2 || nargin>5)
    print_usage();
  endif

  ( isscalar(N) && N > 0 ) || \
      error( "N must be a positive integer" );
  isvector(S) || \
      error( "S must be a vector" );
  S = S(:)';

  if ( nargin < 3 )
    V = 1;
  else
    isvector(V) || \
	error( "V must be a vector" );
    V = V(:)';
  endif
  if ( nargin < 4 )
    m = 1;
  else
    isvector(m) || \
	error( "m must be a vector" );
    m = m(:)';
  endif

  [err S V m] = common_size(S, V, m);
  (err == 0) || \
      error( "S, V and m are of incompatible size" );
  all(m==1) || \
      error( "only single-server nodes are supported" );
  all(S>=0) || \
      error( "S must be >= 0 ");
  all(V>=0) || \
      error( "V must be >= 0" );

  if ( nargin < 5 )
    Z = 0;
  else
    ( isscalar(Z) && Z >= 0 ) || \
        error( "Z must be a nonnegative scalar" );
  endif

  D = S.*V;

  D_max = max(D);
  D_tot = sum(D);
  D_ave = mean(D);
  Xl = N/(D_tot+Z+( (N-1)*D_max )/( 1+Z/(N*D_tot) ) );
  Xu = min( 1/D_max, N/( D_tot+Z+( (N-1)*D_ave )/(1+Z/D_tot) ) );
  Rl = max( N*D_max-Z, D_tot+( (N-1)*D_ave )/( 1+Z/D_tot) );
  Ru = D_tot + ( (N-1)*D_max )/( 1+Z/(N*D_tot) );
endfunction

%!test
%! fail("qnclosedsinglebsb(1)");
%! fail("qnclosedsinglebsb(1, [])", "vector");
%! fail("qnclosedsinglebsb(-1,[1 1 1], [1 1 1])", "positive integer");
%! fail("qnclosedsinglebsb(1,[-1 0 0], [1 1 1])", ">= 0");
%! fail("qnclosedsinglebsb(1,[0 0 0],-1)", ">= 0");
