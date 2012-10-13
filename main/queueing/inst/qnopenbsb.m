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
## @deftypefn {Function File} {[@var{Xl} @var{Xu}, @var{Rl}, @var{Ru}] =} qnopenbsb (@var{lambda}, @dots{})
##
## @cindex bounds, balanced system
## @cindex open network
##
## Compute Balanced System Bounds for open Queueing Networks. 
## This function delegates actual computation to @code{qnopensinglebsb}.
##
## @seealso{qnopensinglebsb}
## 
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnopenbsb( lambda, varargin )
  if ( isscalar(lambda) )
    [Xl Xu Rl Ru] = qnopensinglebsb( lambda, varargin{:} );
  else
    error("This function does not support multiclass networks yet");
  endif
endfunction

%!test
%! fail( "qnopenbsb( 0.1, [] )", "vector" );
%! fail( "qnopenbsb( 0.1, [0 -1])", "vector" );
%! fail( "qnopenbsb( 0, [1 2] )", "lambda" );
%! fail( "qnopenbsb( -1, [1 2])", "lambda" );

