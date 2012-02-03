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
## @deftypefn {Function File} {@var{p} =} dtmc_period (@var{P})
##
## @cindex Markov chain, discrete-time
##
## Compute the period @code{@var{p}(i)} of state @math{i}, for all
## states. The period is defined as the greatest common divisor
## of the number of steps after which a DTMC returns to the starting 
## state. If state @math{i} is non recurrent, then @code{@var{p}(i) = 0}.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function p = dtmc_period( P )

  n = dtmc_check_P(P); # ensure P is a transition probability matrix

  period = zeros(n,n); #  period(i,j) = 1 iff state i returns to itself after exactly j steps

  Pi = P;
  
  for j=1:n
    d = (diag(Pi) > 0); ## d(i) = 1 iff state i returns to itself after j steps
    period(:,j) = d;
    Pi = Pi*P;
  endfor

  p = zeros(1,n);
  F = (find( any(period > 0, 2) )'); # F = set of recurrent states
  for i=F
    p(i) = gcd( find(period(i,:) > 0) );
  endfor
endfunction
%!test
%! P = [0 1 0; 0 0 1; 1 0 0]; # 1 -> 2 -> 3 -> 1
%! p = dtmc_period(P);
%! assert( p, [3 3 3] );

%!test
%! P = [1 0 0; 0 1 0; 0 0 1];
%! p = dtmc_period(P);
%! assert( p, [1 1 1] );

%!test
%! P = [0 1 0; 0 0 1; 0 1 0]; # state 1 is non recurrent
%! p = dtmc_period(P);
%! assert( p, [0 2 2] );

%!test
%! P = [0 0 1 0; 0 0 0 1; 0 1 0 0; 0.5 0 0.5 0];
%! p = dtmc_period(P);
%! assert( p, [1 1 1 1] );
