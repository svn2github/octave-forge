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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopenmulti (@var{lambda}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopenmulti (@var{lambda}, @var{S}, @var{V}, @var{m})
##
## This function is deprecated. Please use @code{qnom} instead.
##
## @seealso{qnom}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/
function [U R Q X] = qnopenmulti( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qnopenmulti is deprecated. Please use qnom instead");
  endif
  [U R Q X] = qnom( varargin{:} );
endfunction
%!test
%! fail( "qnopenmulti([1 1], [.9; 1.0])", "exceeded at center 1");
%! fail( "qnopenmulti([1 1], [0.9 .9; 0.9 1.0])", "exceeded at center 2");
%! qnopenmulti([1 1], [.9; 1.0],[],2); # should not fail, M/M/2-FCFS
%! qnopenmulti([1 1], [.9; 1.0],[],-1); # should not fail, -/G/1-PS
%! fail( "qnopenmulti(1./[2 3], [1.9 1.9 0.9; 2.9 3.0 2.9])", "exceeded at center 2");
%! qnopenmulti(1./[2 3], [1 1.9 0.9; 0.3 3.0 1.5],[],[1 2 1]); # should not fail

%!test
%! V = [1 1; 1 1];
%! S = [1 3; 2 4];
%! lambda = [3/19 2/19];
%! [U R Q X] = qnopenmulti(lambda, S, V);
%! assert( U(1,1), 3/19, 1e-6 );
%! assert( U(2,1), 4/19, 1e-6 );
%! assert( R(1,1), 19/12, 1e-6 );
%! assert( R(1,2), 57/2, 1e-6 );
%! assert( Q(1,1), .25, 1e-6 );
%! assert( Q, R.*X, 1e-5 ); # Little's Law

%!test
%! # example p. 138 Zahorjan et al.
%! V = [ 10 9; 5 4];
%! S = [ 1/10 1/3; 2/5 1];
%! lambda = [3/19 2/19];
%! [U R Q X] = qnopenmulti(lambda, S, V);
%! assert( X(1,1), 1.58, 1e-2 );
%! assert( U(1,1), .158, 1e-3 );
%! assert( R(1,1), .158, 1e-3 ); # modified from the original example, as the reference above considers R as the residence time, not the response time
%! assert( Q(1,1), .25, 1e-2 );
%! assert( Q, R.*X, 1e-5 ); # Little's Law
