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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopensingle (@var{lambda}, @var{S}, @var{V}) 
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopensingle (@var{lambda}, @var{S}, @var{V}, @var{m})
##
## This function is deprecated. Please use @code{qnos} instead.
##
## @seealso{qnos}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnopensingle( varargin )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "qnopensingle is deprecated. Please use qnos instead");
  endif
  [U R Q X] = qnos( varargin{:} );
endfunction
%!test
%! lambda = 0;
%! S = [1 1 1];
%! V = [1 1 1];
%! fail( "qnopensingle(lambda,S,V)","lambda must be");
%! lambda = 1;
%! S = [1 0 1];
%! fail( "qnopensingle(lambda,S,V)","S must be");
%! S = [1 1 1];
%! m = [1 1];
%! fail( "qnopensingle(lambda,S,V,m)","m must be a vector");
%! V = [1 1 1 1];
%! fail( "qnopensingle(lambda,S,V)","3 elements");
%! fail( "qnopensingle(1.0, [0.9 1.2], [1 1])", "exceeded at center 2");
%! fail( "qnopensingle(1.0, [0.9 2.0], [1 1], [1 2])", "exceeded at center 2");
%! qnopensingle(1.0, [0.9 1.9], [1 1], [1 2]); # should not fail
%! qnopensingle(1.0, [0.9 1.9], [1 1], [1 0]); # should not fail
%! qnopensingle(1.0, [1.9 1.9], [1 1], [0 0]); # should not fail
%! qnopensingle(1.0, [1.9 1.9], [1 1], [2 2]); # should not fail
 
%!test
%! # Example 34.1 p. 572 Bolch et al.
%! lambda = 3;
%! V = [16 7 8];
%! S = [0.01 0.02 0.03];
%! [U R Q X] = qnopensingle( lambda, S, V );
%! assert( R, [0.0192 0.0345 0.107], 1e-2 );
%! assert( U, [0.48 0.42 0.72], 1e-2 );
%! assert( Q, R.*X, 1e-5 ); # check Little's Law

%!test
%! # Example p. 113, Lazowska et al.
%! V = [121 70 50];
%! S = [0.005 0.03 0.027];
%! lambda=0.3;
%! [U R Q X] = qnopensingle( lambda, S, V );
%! assert( U(1), 0.182, 1e-3 );
%! assert( X(1), 36.3, 1e-2 );
%! assert( Q(1), 0.222, 1e-3 );
%! assert( Q, R.*X, 1e-5 ); # check Little's Law

%!test
%! lambda=[1];
%! P=[0];
%! V=qnvisits(P,lambda);
%! S=[0.25];
%! [U1 R1 Q1 X1]=qnopensingle(sum(lambda),S,V); 
%! [U2 R2 Q2 X2]=qnmm1(lambda(1),1/S(1));
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );
%! assert( X1, X2, 1e-5 );

## Check if processing capacity is properly accounted for
%!test
%! lambda = 1.1;
%! V = 1;
%! m = [2];
%! S = [1];
%! [U1 R1 Q1 X1] = qnopensingle(lambda,S,V,m); 
%! m = [-1];
%! lambda = 90.0;
%! [U1 R1 Q1 X1] = qnopensingle(lambda,S,V,m); 

