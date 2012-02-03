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
## @deftypefn {Function File} {@var{p} =} ctmc_bd (@var{birth}, @var{death})
##
## @cindex Markov chain, continuous time
## @cindex Birth-death process
##
## Compute the steady-state solution of a birth-death process with state
## space @math{(1, @dots{}, N)}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item birth
## Vector with @math{N-1} elements, where @code{@var{birth}(i)} is the
## transition rate from state @math{i} to state @math{i+1}.
##
## @item death
## Vector with @math{N-1} elements, where @code{@var{death}(i)} is the
## transition rate from state @math{i+1} to state @math{i}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item p
## @code{@var{p}(i)} is the steady-state probability that the system is
## in state @math{i}, @math{i=1, @dots{}, N}.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function p = ctmc_bd( birth, death )

  if ( nargin != 2 ) 
    print_usage();
  endif

  ( isvector( birth ) && isvector( death ) ) || \
      usage( "birth and death must be vectors" );
  birth = birth(:); # make birth a column vector
  death = death(:); # make death a column vector
  size_equal( birth, death ) || \
      usage( "birth and death must have the same length" );
  all( birth >= 0 ) || \
      usage( "birth must be >= 0" );
  all( death >= 0 ) || \
      usage( "death must be >= 0" );

  n = length(birth) + 1; # number of states 

  ## builds the transition probability matrix
  Q = diag( birth, 1 ) + diag( death, -1 );
  Q -= diag( sum(Q,2) );
  p = ctmc( Q );
endfunction
%!test
%! birth = [ 1 1 1 ];
%! death = [ 2 2 2 ];
%! result = ctmc_bd( birth, death );
%! assert( result, [ 8/15 4/15 2/15 1/15 ], 1e-5 );
