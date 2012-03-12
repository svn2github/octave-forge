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
## @deftypefn {Function File} {[@var{result} @var{err}] =} dtmc_check_P (@var{P})
##
## @cindex Markov chain, discrete time
##
## If @var{P} is a valid transition probability matrix, return
## the size (number of rows or columns) of @var{P}. If @var{P} is not
## a transition probability matrix, set @var{result} to zero, and
## @var{err} to an appropriate error string.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [result err] = dtmc_check_P( P )

  persistent epsilon = 10*eps;

  if ( nargin != 1 )
    print_usage();
  endif

  result = 0;

  if ( !issquare(P) )
    err = "P is not a square matrix";
    return;
  endif
  
  if (  any(any(P <0)) || norm( sum(P,2) - 1, "inf" ) > epsilon )
    err = "P is not a stochastic matrix";
    return;
  endif

  result = rows(P);
  err = "";
endfunction
%!test
%! [r err] = dtmc_check_P( [1 1 1; 1 1 1] );
%! assert( r, 0 );
%! assert( index(err, "square") > 0 );

%!test
%! [r err] = dtmc_check_P( [1 0 0; 0 0.5 0; 0 0 0] );
%! assert( r, 0 );
%! assert( index(err, "stochastic") > 0 );

%!test
%! P = [0 1; 1 0];
%! assert( dtmc_check_P(P), 2 );

%!test
%! P = dtmc_bd( linspace(0.1,0.4,10), linspace(0.4,0.1,10) );
%! assert( dtmc_check_P(P), rows(P) );