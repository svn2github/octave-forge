## Copyright (C) 2002 David Bateman
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} gfft (@var{x})
##
## If @var{x} is a column vector, finds the FFT over the primitive element
## of the Galois Field of @var{x}. If @var{x} is in the Galois  Field
## GF(2^@var{m}), then @var{x} must have @code{2^@var{m} - 1} elements.
## @end deftypefn
## @seealso{fft}

## PKG_ADD: dispatch ("fft", "gfft", "galois");
function y = gfft(x)

  if (nargin != 1)
    error ("usage: y = gfft (x)");
  endif
    
  if (!isgalois(x))
    error("gfft: argument must be a galois variable");
  endif

  n = 2^x.m - 1;
  if (n > 255)
    error ([ "gfft: argument must be in Galois Field GF(2^m), where", ...
           " m is not greater than 8"]); 
  endif
  
  alph = gf(2, x.m, x.prim_poly);
  [nr,nc] = size(x);
  if ((nc == 1) & (nr == n))
    y = gdftmtx(alph) * x;
  elseif ((nc == n) & (nr == 1))
    y = (gdftmtx(alph) * x')';
  else
    error ("gfft: argument must be a vector in GF(2^m) of length 2^m-1");
  endif
    
endfunction
