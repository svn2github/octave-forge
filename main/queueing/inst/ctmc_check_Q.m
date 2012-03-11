## Copyright (C)2012 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{result} @var{err}] =} ctmc_check_Q (@var{Q})
##
## @cindex Markov chain, continuous time
##
## If @var{Q} is a valid infinitesimal generator matrix, return
## the size (number of rows or columns) of @var{Q}. If @var{Q} is not
## an infinitesimal generator matrix, set @var{result} to zero, and
## @var{err} to an appropriate error string.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [result err] = ctmc_check_Q( Q )

  persistent epsilon = 10*eps;

  if ( nargin != 1 )
    print_usage();
  endif

  result = 0;

  if ( !issquare(Q) )
    err = "P is not a square matrix";
    return;
  endif
  
  if ( norm( sum(Q,2), "inf" ) > epsilon )
    err = "Q is not an infinitesimal generator matrix";
    return;
  endif

  result = rows(Q);
  err = "";
endfunction
