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
## @deftypefn {Function File} {} lin2mu (@var{x}, @var{bps})
## If the matrix @var{x} represents audio data in linear encoding, 
## @code{lin2mu} converts it to mu-law encoding.  The optional argument
## @var{bps} specifies whether the output data uses 8 bit samples (range
## -128 to 127), 16 bit samples (range -32768 to 32767) or default 0 for
## real values (range -1 to 1).
## @end deftypefn
## @seealso{mu2lin, loadaudio, saveaudio, playaudio, setaudio, and record}

## Author: AW <Andreas.Weingessel@ci.tuwien.ac.at>
## Created: 17 October 1994
## Adapted-By: jwe

## Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
##    handle [-1,1] input range
## 2001-10-22 Paul Kienzle
## * restore Octave's guessing behaviour for precision, but issue warning

function y = lin2mu (x, bit)

  if (nargin == 1)
    range = max(abs(x(:)));
    if (range <= 1) 
      bit = 0;
    elseif (range <= 128) 
      bit = 8;
      warning ("lin2mu: no precision specified, so using %d", bit);
    else
      bit = 16;
    endif
  elseif (nargin == 2)
    if (bit != 0 && bit != 8 && bit != 16)
      error ("lin2mu: bit must be either 0, 8 or 16");
    endif
  else
    usage ("y = lin2mu (x, bit)");
  endif


  ## transform real and 8-bit format to 16-bit
  if (bit == 0)
    x = 32768 .* x;
  elseif (bit == 8)
    x = 256 .* x;
  endif

  ## determine sign of x, set sign(0) = 1.
  sig = sign(x) + (x == 0);

  ## take absolute value of x, but force it to be smaller than 32636;
  ## add bias
  x = min (abs (x), 32635 * ones (size (x))) + 132;

  ## find exponent and fraction of bineary representation
  [f, e] = log2 (x);

  y = 64 * sig - 16 * e - fix (32 * f) + 335;

endfunction
