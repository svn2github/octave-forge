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
## @deftypefn {Function File} {} invhilb (@var{n})
## Return the inverse of a Hilbert matrix of order @var{n}.  This is exact.
## Compare with the numerical calculation of @code{inverse (hilb (n))},
## which suffers from the ill-conditioning of the Hilbert matrix, and the
## finite precision of your computer's floating point arithmetic.
## @end deftypefn
## @seealso{hankel, vander, sylvester_matrix, hilb, and toeplitz}

## Author: jwe
## Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
##    vectorize for speed


function retval = invhilb (n)

  if (nargin != 1)
    usage ("invhilb (n)");
  endif

###
###             1     Prod(k+i-1) Prod(k+j-1)
### A(i,j) = -------  ----------- -----------
###          (i+j-1)   Prod(k-i)   Prod(k-j)
###                    k!=i        k!=i
###
### Consider starting at the diagonal and building the matrix along the
### rows.  That is, find A(i,j+1) in terms of A(i,j).
### Ignoring the 1/(i+j-1) for the moment, A(i,j+1)/A(i,j) is:
###
###      Prod(k+j)     Prod(k-j)       (n+j-1) (n+1-j)        (n)^2
###     -----------  ------------- =   ------- ------- = 1 - -------
###     Prod(k+j-1)  Prod(k-(j+1))      (j-1)   (1-j)        (j-i)^2
###
### So we can generate a row by taking the cumulative product of
### (1 - (n/(j-1))^2), multiplying by the initial value Prod(k+i-1)/Prod(k-i)
### and dividing by 1/(i+j-1).  Since it is symmetric, we only need to
### generate half a row.
###
### The cumulative sum does introduce some error
###    err_relative < 3*eps for n < 10
### but rounding gets rid of that.  Error stays under control until at
### least n=25 (err_relative < 10*eps).  After that I don't know since
### I get bored of waiting for the old invhilb.  It is a factor of 100
### slower at n=25, and going up as cube rather than a square.
###
### Note that the remaining for loop could probably be eliminated as
### well, but there is hardly any point. invhilb -> Inf for n>134, and
### that only takes 0.5 seconds to compute on my machine.  And it's not
### like invhilb gets called a bunch, either, unlike e.g., an FFT which
### operates directly on a signal.

  nmax = length (n);
  if (nmax == 1)
    retval = zeros (n);
    for l = 1:n
      den = [ 1-l:n-l ]; 
      den (l) = [];
      lprod = prod (l:l+n-1) / prod (den);
      if l==n
	retval (l,l) = lprod^2 / (l+l-1);
      else
	row = [ lprod ;  1-(n./[l:n-1]').^2 ];
      	retval (l:n, l) = lprod * cumprod (row) ./ ([l:n]' + l-1);
      endif
    endfor
    retval = round (retval + retval.' - diag (diag (retval)));
  else
    error ("hilb: expecting scalar argument, found something else");
  endif

endfunction
