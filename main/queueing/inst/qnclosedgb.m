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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Ql}, @var{Qu}] =} qnclosedgb (@var{N}, @var{D}, @var{Z})
##
## This function is deprecated. Please use @code{qncsgb} instead.
##
## @seealso{qncsgb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [X_lower X_upper Q_lower Q_upper] = qnclosedgb( N, D, Z )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "Function qnclosedgb is deprecated. Please use qncsgb instead");
  endif
  if ( nargin < 3 ) 
    [X_lower X_upper R_lower R_upper Q_lower Q_upper] = qncsgb( N, D );
  else
    [X_lower X_upper R_lower R_upper Q_lower Q_upper] = qncsgb( N, D, ones(size(D)), ones(size(D)), Z);
  endif
endfunction

%!test
%! fail( "qnclosedgb( 1, [] )", "vector" );
%! fail( "qnclosedgb( 1, [0 -1])", "vector" );
%! fail( "qnclosedgb( 0, [1 2] )", ">0" );
%! fail( "qnclosedgb( -1, [1 2])", ">0" );

%!# shared test function
%!function test_gb( D, expected, Z=0 )
%! for i=1:rows(expected)
%!   N = expected(i,1);
%!   [X_lower X_upper Q_lower Q_upper] = qnclosedgb(N,D,Z);
%!   X_exp_lower = expected(i,2);
%!   X_exp_upper = expected(i,3);
%!   assert( [N X_lower X_upper], [N X_exp_lower X_exp_upper], 1e-4 )
%! endfor

%!xtest
%! # table IV
%! D = [ 0.1 0.1 0.09 0.08 ];
%! #            N  X_lower  X_upper
%! expected = [ 2  4.3040   4.3174; ...
%!              5  6.6859   6.7524; ...
%!              10 8.1521   8.2690; ...
%!              20 9.0947   9.2431; ...
%!              80 9.8233   9.8765 ];
%! test_gb(D, expected);

%!xtest
%! # table V
%! D = [ 0.1 0.1 0.09 0.08 ];
%! Z = 1;
%! #            N  X_lower  X_upper
%! expected = [ 2  1.4319   1.5195; ...
%!              5  3.3432   3.5582; ...
%!              10 5.7569   6.1410; ...
%!              20 8.0856   8.6467; ...
%!              80 9.7147   9.8594];
%! test_gb(D, expected, Z);

%!test
%! P = [0 0.3 0.7; 1 0 0; 1 0 0];
%! S = [1 0.6 0.2];
%! m = ones(1,3);
%! V = qnvisits(P);
%! Nmax = 20;
%! tol = 1e-5; # compensate for numerical errors
%! ## Test case with Z>0
%! for n=1:Nmax
%!   [X_gb_lower X_gb_upper Q_gb_lower Q_gb_upper] = qnclosedgb(n, S.*V, 2);
%!   [U R Q X] = qnclosed( n, S, V, m, 2 );
%!   X_mva = X(1)/V(1);
%!   assert( X_gb_lower <= X_mva+tol );
%!   assert( X_gb_upper >= X_mva-tol );
%!   assert( Q_gb_lower <= Q+tol ); # compensate for numerical errors
%!   assert( Q_gb_upper >= Q-tol ); # compensate for numerical errors
%! endfor

%!test
%! P = [0 0.3 0.7; 1 0 0; 1 0 0];
%! S = [1 0.6 0.2];
%! m = ones(1,3);
%! V = qnvisits(P);
%! Nmax = 20;
%! tol = 1e-5; # compensate for numerical errors
%!
%! ## Test case with Z=0
%! for n=1:Nmax
%!   [X_gb_lower X_gb_upper Q_gb_lower Q_gb_upper] = qnclosedgb(n, S.*V, 0);
%!   [U R Q X] = qnclosed( n, S, V, m, 0 );
%!   X_mva = X(1)/V(1);
%!   assert( X_gb_lower <= X_mva+tol );
%!   assert( X_gb_upper >= X_mva-tol );
%!   assert( Q_gb_lower <= Q+tol );
%!   assert( Q_gb_upper >= Q-tol );
%! endfor
