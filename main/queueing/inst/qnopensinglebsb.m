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
## @deftypefn {Function File} {[@var{Xl} @var{Xu}, @var{Rl}, @var{Ru}] =} qnopensinglebsb (@var{lambda}, @var{S})
## @deftypefnx {Function File} {[@var{Xl} @var{Xu}, @var{Rl}, @var{Ru}] =} qnopensinglebsb (@var{lambda}, @var{S}, @var{V})
##
## @cindex bounds, balanced system
## @cindex open network
##
## Compute Balanced System Bounds for single-class, open networks.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda 
## overall arrival rate to the system (scalar). Abort if
## @code{@var{lambda} < 0 }
##
## @item S
## @code{@var{S}(k)} is the mean service time at center @math{k}.
## (@code{@var{S}(k) @geq{} 0} for all @math{k}).
##
## @item V
## @code{@var{V}(k)} is the mean number of visits at center @math{k}.
## (@code{@var{V}(k) @geq{} 0} for all @math{k}). Default is 1
## for all @math{k}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## @item Xu
## Lower and upper bounds on the system throughput. Note: @var{Xl} will
## be always be @code{-inf}, since there can be no lower bound on open
## networks throughput.
##
## @item Rl
## @itemx Ru
## Lower and upper bounds on the system response time.
##
## @end table
##
## @seealso{qnopenab}
## 
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [X_lower X_upper R_lower R_upper] = qnopensinglebsb( lambda, S, V )
  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif
  ( isscalar(lambda) && lambda > 0 ) || \
      error( "lambda must be a positive scalar" );
  ( isvector(S) && length(S)>0 && all( S>=0 ) ) || \
      error( "S must be a vector of nonnegative scalars" );
  S = S(:)';
  if ( nargin < 3 )
    V = ones(size(S));
  else
    ( isvector(V) && size_equal(S,V) && all( V>=0 ) ) || \
	error( "V must be a vector >=0 with %d elements", length(S));
    V = V(:)';
  endif

  D = S .* V;

  D_max = max(D);
  D_tot = sum(D);
  D_ave = mean(D_tot);
  X_upper = 1/D_max;
  X_lower = -inf;
  R_lower = D_tot / (1-lambda*D_ave);
  R_upper = D_tot / (1-lambda*D_max);
endfunction

%!test
%! fail( "qnopenbsb( 0.1, [] )", "vector" );
%! fail( "qnopenbsb( 0.1, [0 -1])", "vector" );
%! fail( "qnopenbsb( 0, [1 2] )", "lambda" );
%! fail( "qnopenbsb( -1, [1 2])", "lambda" );

