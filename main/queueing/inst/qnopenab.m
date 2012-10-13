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
## @deftypefn {Function File} {[@var{Xu}, @var{Rl}] =} qnopenab (@var{lambda}, @dots{} )
##
## @cindex bounds, asymptotic
## @cindex open network
##
## Compute Asymptotic Bounds for open networks with single or multiple classes of customers.
##
## This function dispatches the computation to @code{qnopensingleab} or @code{qnopenmultiab}.
##
## @seealso{qnopensingleab, qnopenmultiab}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnopenab( lambda, varargin )
  if ( nargin < 1 )
    print_usage();
  endif
  if ( isscalar(lambda) )
    [Xl Xu Rl Ru] = qnopensingleab(lambda, varargin{:} );
  else
    [Xl Xu Rl Ru] = qnopenmultiab(lambda, varargin{:} );
  endif
endfunction

%!test
%! fail( "qnopenab( 0.1, [] )", "vector" );
%! fail( "qnopenab( 0.1, [0 -1])", "vector" );
%! fail( "qnopenab( 0, [1 2] )", "lambda" );
%! fail( "qnopenab( -1, [1 2])", "lambda" );