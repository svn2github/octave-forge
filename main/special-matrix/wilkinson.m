## Copyright (C) 1999 Peter Ekberg
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## usage: wilkinson (n)
##
## Return the Wilkinson matrix of order n.
##
## See also: hankel, vander, sylvester_matrix, hilb, invhilb, toeplitz
##           hadamard, rosser, compan, pascal

## Author: Peter Ekberg
##         (peda)

function retval = wilkinson (n)

  if (nargin != 1)
    usage ("wilkinson (n)");
  endif

  nmax = length (n);
  if ~(nmax == 1)
    error ("wilkinson: expecting scalar argument, found something else");
  endif

  side = ones(n-1,1);
  center = abs(-(n-1)/2:(n-1)/2);
  retval = diag(side, -1) + diag(center) + diag(side, 1);

endfunction
