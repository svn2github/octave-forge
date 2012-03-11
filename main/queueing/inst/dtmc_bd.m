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
## @deftypefn {Function File} {@var{P} =} dtmc_bd (@var{birth}, @var{death})
##
## @cindex Markov chain, discrete time
## @cindex Birth-death process
##
## Returns the @math{N \times N} transition probability matrix @math{P}
## for a birth-death process with given rates.
##
## @strong{INPUTS}
##
## @table @var
##
## @item birth
## Vector with @math{N-1} elements, where @code{@var{birth}(i)} is the
## transition probability from state @math{i} to state @math{i+1}.
##
## @item death
## Vector with @math{N-1} elements, where @code{@var{death}(i)} is the
## transition probability from state @math{i+1} to state @math{i}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item P
## Transition probability matrix for the birth-death process.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function P = dtmc_bd( birth, death )

  if ( nargin != 2 ) 
    print_usage();
  endif

  ( isvector( birth ) && isvector( death ) ) || \
      usage( "birth and death must be vectors" );
  birth = birth(:); # make birth a column vector
  death = death(:); # make death a column vector
  size_equal( birth, death ) || \
      usage( "birth and death vectors must have the same length" );
  all( birth >= 0 ) || \
      usage( "birth probabilities must be >= 0" );
  all( death >= 0 ) || \
      usage( "death probabilities must be >= 0" );
  all( ([birth; 0] + [0; death]) <= 1 ) || \
      usage( "Inconsistent birth/death probabilities");
  ## builds the infinitesimal generator matrix
  P = diag( birth, 1 ) + diag( death, -1 );
  P += diag( 1-sum(P,2) );
endfunction
%!test
%! birth = [.5 .5 .3];
%! death = [.6 .2 .3];
%! fail("dtmc_bd(birth,death)","Inconsistent");

%!demo
%! birth = [ .2 .3 .4 ];
%! death = [ .1 .2 .3 ];
%! P = dtmc_bd( birth, death );
%! disp(P)

