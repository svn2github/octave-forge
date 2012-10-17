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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedpb (@var{N}, @var{D} )
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedpb (@var{N}, @var{D}, @var{Z} )
##
## This function is deprecated. Please use @code{qncspb} instead.
##
## @seealso{qncspb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [X_lower X_upper] = qnclosedpb( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "Function qnclosedpb is deprecated. Please use qncspb instead");
  endif
  [X_lower X_upper R_lower R_upper] = qncspb( varargin{:} );
endfunction

%!test
%! fail( "qnclosedpb( 1, [] )", "vector" );
%! fail( "qnclosedpb( 1, [0 -1])", "vector" );
%! fail( "qnclosedpb( 0, [1 2] )", "positive integer" );
%! fail( "qnclosedpb( -1, [1 2])", "positive integer" );

%!# shared test function
%!function test_pb( D, expected )
%! for i=1:rows(expected)
%!   N = expected(i,1);
%!   [X_lower X_upper] = qnclosedpb(N,D);
%!   X_exp_lower = expected(i,2);
%!   X_exp_upper = expected(i,3);
%!   assert( [N X_lower X_upper], [N X_exp_lower X_exp_upper], 1e-4 )
%! endfor

%!test
%! # table IV
%! D = [ 0.1 0.1 0.09 0.08 ];
%! #            N  X_lower  X_upper
%! expected = [ 2  4.3174   4.3174; ... 
%!              5  6.6600   6.7297; ...
%!              10 8.0219   8.2700; ...
%!              20 8.8672   9.3387; ...
%!              80 9.6736   10.000 ];
%! test_pb(D, expected);
