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
## @deftypefn {Function File} {[@var{Xu}, @var{Rl}] =} qnopenmultiab (@var{lambda}, @var{S})
## @deftypefnx {Function File} {[@var{Xu}, @var{Rl}] =} qnopenmultiab (@var{lambda}, @var{S}, @var{V})
##
## @cindex bounds, asymptotic
## @cindex open network
##
## Compute Asymptotic Bounds for open, multiclass networks.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## @code{@var{lambda}(c)} is the class @math{c} arrival rate to the
## system.
##
## @item S
## @code{@var{S}(c, k)} is the mean service time of class @math{c}
## requests at center @math{k}. (@code{@var{S}(c, k) @geq{} 0} for all
## @math{k}).
##
## @item V
## @code{@var{V}(c, k)} is the mean number of visits of class @math{c}
## requests at center @math{k}. (@code{@var{V}(c, k) @geq{} 0} for all
## @math{k}). Default is 1 for all @math{k}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xu
## Upper bound on the system throughput.
##
## @item Rl
## Lower bound on the system response time.
##
## @end table
##
## @seealso{qnopenbsb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [X_upper R_lower] = qnopenmultiab( lambda, S, V )
  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif
  ( isvector(lambda) && all(lambda > 0) ) || \
      error( "lambda must be a vector >= 0" );
  lambda = lambda(:)';
  C = length(lambda);
  ( ismatrix(S) && rows(S)==C && all(all( S>=0 )) ) || \
      error( "S must be a matrix >=0 with %d rows", C );
  K = columns(S);
  if ( nargin < 3 )
    V = ones(size(S));
  else
    ( ismatrix(V) && size_equal(S,V) && all(all( V>=0 )) ) || \
	error( "V must be a %d x %d matrix >=0", C, K);
  endif
  D = S.*V;
  X_upper = 1./max(D,[],2)';
  R_lower = sum(D,2)';
endfunction

%!test
%! fail( "qnopenmultiab( [1 1], [1 1 1; 1 1 1; 1 1 1] )", "2 rows" );
