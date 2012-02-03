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
## @deftypefn {Function File} {[@var{Xu}, @var{Rl}, @var{Ru}] =} qnopenbsb (@var{lambda}, @var{D})
##
## @cindex bounds, balanced system
## @cindex open network
##
## Compute Balanced System Bounds for single-class, open Queueing Networks
## with @math{K} service centers.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda 
## overall arrival rate to the system (scalar). Abort if
## @code{@var{lambda} < 0 }
##
## @item D 
## @code{@var{D}(k)} is the service demand at center @math{k}.
## The service demand vector @var{D} must be nonempty, and all demands
## must be nonnegative (@code{@var{D}(k) @geq{} 0} for all @math{k}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## Lower bound on the system throughput.
##
## @item Rl
## @itemx Ru
## Lower and upper bound on the system response time.
##
## @end table
##
## @seealso{qnopenab}
## 
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [X_upper R_lower R_upper] = qnopenbsb( lambda, D )
  if ( nargin != 2 )
    print_usage();
  endif
  ( isscalar(lambda) && lambda>0 ) || \
      usage( "lambda must be a positive scalar" );
  ( isvector(D) && length(D)>0 && all(D>=0) ) || \
      usage( "D must be a vector of nonnegative floats" );

  D_max = max(D);
  D_tot = sum(D);
  D_ave = mean(D_tot);
  X_upper = 1/D_max;
  R_lower = D_tot / (1-lambda*D_ave);
  R_upper = D_tot / (1-lambda*D_max);
endfunction

%!test
%! fail( "qnopenbsb( 0.1, [] )", "vector" );
%! fail( "qnopenbsb( 0.1, [0 -1])", "vector" );
%! fail( "qnopenbsb( 0, [1 2] )", "lambda" );
%! fail( "qnopenbsb( -1, [1 2])", "lambda" );

