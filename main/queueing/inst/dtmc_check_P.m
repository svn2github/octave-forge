## Copyright (C) 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {@var{result} =} dtmc_check_P (@var{P})
##
## @cindex Markov chain, discrete time
##
## Returns the size (number of rows or columns) of square matrix
## @var{P}, if and only if @var{P} is a valid transition probability
## matrix. This means that (i) all elements of @var{P} must be nonnegative, 
## and (ii) the sum of each row must be 1.0. 
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function result = dtmc_check_P( P )

  persistent epsilon = 10*eps;

  if ( nargin != 1 )
    print_usage();
  endif

  issquare(P) || \
      usage( "P must be a square matrix" );
  
  ( all(all(P >= 0) ) && norm( sum(P,2) - 1, "inf" ) < epsilon ) || \
      error( "P is not a stochastic matrix" );

  result = rows(P);
endfunction
%!test
%! fail("dtmc_check_P( [1 1 1; 1 1 1] )", "square");
%! fail("dtmc_check_P( [1 0 0; 0 0.5 0; 0 0 0] )", "stochastic" );

%!test
%! P = [0 1; 1 0];
%! assert( dtmc_check_P(P), 2 );