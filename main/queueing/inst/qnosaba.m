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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnosaba (@var{lambda}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnosaba (@var{lambda}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnosaba (@var{lambda}, @var{S}, @var{V}, @var{m})
##
## @cindex bounds, asymptotic
## @cindex open network
##
## Compute Asymptotic Bounds for open, single-class networks.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## Arrival rate of requests (@code{@var{lambda} @geq{} 0}).
##
## @item D
## @code{@var{D}(k)} is the service demand at center @math{k}.
## (@code{@var{D}(k) @geq{} 0} for all @math{k}).
##
## @item S
## @code{@var{S}(k)} is the mean service time at center @math{k}.
## (@code{@var{S}(k) @geq{} 0} for all @math{k}).
##
## @item V
## @code{@var{V}(k)} is the mean number of visits to center @math{k}.
## (@code{@var{V}(k) @geq{} 0} for all @math{k}).
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}.
## This function only supports @math{M/M/1} queues, therefore
## @var{m} must be @code{ones(size(S))}. 
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## @item Xu
## Lower and upper bounds on the system throughput. @var{Xl} is
## always set to @math{0} since there can be no lower bound on the
## throughput of open networks.
##
## @item Rl
## @item Ru
## Lower and upper bounds on the system response time. @var{Ru}
## is always set to @code{+inf} since there can be no upper bound on the
## throughput of open networks.
##
## @end table
##
## @seealso{qnopenmultiab}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [X_lower X_upper R_lower R_upper] = qnosaba( lambda, S, V, m )
  if ( nargin < 2 || nargin > 4 )
    print_usage();
  endif
  isscalar(lambda) || error("lambda must be a scalar");
  lambda > 0 || error("lambda must be >0");
  ( isvector(S) && length(S)>0 ) || \
      error( "S/D must be a nonempty vector" );
  all(S>=0) || \
      error("S/D must contain nonnegative values");
  S = S(:)';
  if ( nargin < 3 )
    D = S;
  else
    ( isvector(V) && length(V) == length(S) ) || \
	error( "V must be a vector with %d elements", length(S));
    all(V>=0) || \
	error( "V must contain nonnegative values");
    D = S .* V;
  endif
  if ( nargin < 4 )
    ## nothing
  else
    ( isvector(m) && length(m) == length(S) ) || \
	error("m must be a vector wiht %d elements", length(S));
    all(m==1) || \
	error("this function only supports M/M/1 queues");
  endif

  X_lower = 0;
  X_upper = 1/max(D);
  R_lower = sum(D);
  R_upper = +inf;
endfunction

%!test
%! fail( "qnosaba( 0.1, [] )", "vector" );
%! fail( "qnosaba( 0.1, [0 -1])", "nonnegative" );
%! fail( "qnosaba( 0, [1 2] )", "lambda" );
%! fail( "qnosaba( -1, [1 2])", "lambda" );
%! fail( "qnosaba( 1, [1 2 3], [1 2] )", "3 elements");
%! fail( "qnosaba( 1, [1 2 3], [-1 2 3] )", "nonnegative");

%!test
%! [Xl Xu Rl Ru] = qnosaba( 1, [1 1] );
%! assert( Xl, 0 );
%! assert( Ru, +inf );
