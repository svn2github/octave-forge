## Copyright (C) 2000 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## usage: [z, n] = cplxpair(z [,tol])
##
## Sort the numbers z into complex conjugate pairs ordered by increasing
## real part, or with identical real parts, increasing imaginary
## magnitude. Place the negative imaginary complex number first within
## each pair.  Place all the real numbers after all the complex pairs
## (those with abs(imag(z)/z) < tol).  Signal an error if some complex
## numbers could not be paired.  Requires all complex numbers to be exact
## conjugates within tol, or signals an error.  tol defaults to 100*eps.
## Note that there are no guarantees on the order of the returned pairs
## with identical real parts but differing imaginary parts.
##
## Returns the ordered list of values, plus the number of values which
## were complex.
##
## Example 
##     [ cplxpair (exp(2i*pi*[0:4]'/5)), exp(2i*pi*[3; 2; 4; 1; 0]/5) ]

## TODO: subsort returned pairs by imaginary magnitude
## TODO: Consider removing extra return value (the number of complex
## TODO:    values in the list) for exact compatibility
## TODO: Why doesn't exp(2i*pi*[0:4]'/5) produce exact conjugates. Does
## TODO:    it in Matlab?  The reason is that complex pairs are supposed
## TODO:    to be exact conjugates, and not rely on a tolerance test.
function [y, n] = cplxpair(z, tol)

  if nargin < 1 || nargin > 2 
    usage ("[z, n] = cplxpair (z [, tol]);"); 
  endif
  if nargin < 2, tol = 100*eps; endif

  y = zeros (size (z));
  if (length (z) == 0), return; endif

  ## Sort the sequence in terms of increasing real values
  [q, idx] = sort (real (z));
  z = z (idx);

  ## Put the purely real values at the end of the returned list
  idx = find ( abs(imag(z)) ./ (abs(z)+realmin) < tol );
  n = length (z) - length (idx);
  if (length (idx) > 0)
    y (n+1 : length(z)) = z (idx);
    z (idx) = [];
  endif

  ## For each remaining z, place the value and its conjugate at the
  ## start of the returned list, and remove them from further
  ## consideration.
  for i=1:2:n
    if (i+1 > n)
      error ("cplxpair could not pair all complex numbers");
    endif
    [v, idx] = min ( abs (z(i+1:n) - conj(z(i))) );
    if (v > tol)
      error ("cplxpair could not pair all complex numbers");
    endif
    if imag(z(i)) < 0
      y ([i, i+1]) = z ([i, idx+i]);
    else
      y ([i, i+1]) = z ([idx+i, i]);
    endif
    z (idx+i) = z (i+1);
  endfor

endfunction

%!demo
%! [ cplxpair (exp(2i*pi*[0:4]'/5)), exp (2i*pi*[3; 2; 4; 1; 0]/5) ]

%!assert (isempty(cplxpair([])));
%!assert (cplxpair(1), 1)
%!assert (cplxpair([1+1i, 1-1i]), [1-1i, 1+1i])
%!assert (cplxpair([1+1i, 1+1i, 1, 1-1i, 1-1i, 2]), \
%!	  [1-1i, 1+1i, 1-1i, 1+1i, 1, 2])
%!assert (cplxpair([1+1i; 1+1i; 1; 1-1i; 1-1i; 2]), \
%!	  [1-1i; 1+1i; 1-1i; 1+1i; 1; 2]) 
%!assert (cplxpair([0, 1, 2]), [0, 1, 2]);

%!shared z
%! z=exp(2i*pi*[4; 3; 5; 2; 6; 1; 0]/7);
%!assert (cplxpair(z(randperm(7))), z);
%!assert (cplxpair(z(randperm(7))), z);
%!assert (cplxpair(z(randperm(7))), z);

%!## tolerance test
%!assert (cplxpair([1i, -1i, 1+(1i*eps)],2*eps), [-1i, 1i, 1+(1i*eps)]);
