## Copyright (C) 1996, 1997 John W. Eaton
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} hilb (@var{n})
## Return the Hilbert matrix of order @var{n}.  The
## @iftex
## @tex
## $i,\,j$
## @end tex
## @end iftex
## @ifinfo
## i, j
## @end ifinfo
## element of a Hilbert matrix is defined as
## @iftex
## @tex
## $$
## H (i, j) = {1 \over (i + j - 1)}
## $$
## @end tex
## @end iftex
## @ifinfo
##
## @example
## H (i, j) = 1 / (i + j - 1)
## @end example
## @end ifinfo
## @end deftypefn
## @seealso{hankel, vander, sylvester_matrix, invhilb, and toeplitz}

## Author: jwe
## Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
##    vectorize for speed

function retval = hilb (n)

  if (nargin != 1)
    usage ("hilb (n)");
  endif
  
  if (!is_scalar (n) || n != fix (n) || n < 1)
    error ("hilb: expecting a positive integer"); 
  endif
  
  retval = [1:n]' * ones (1, n) + ones (n, 1) * [0:n-1];
  retval = 1 ./ retval;

endfunction
