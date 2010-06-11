## Copyright (C) 2008, 2009 Luca Favatella <slackydeb@gmail.com>
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## Some tests.


## @deftypefn {Function File} {} __bin2hex__ (@var{s})
## Return the hexadecimal number corresponding to the binary number
## stored in the string @var{s}.
##
## If @var{s} is a string matrix, returns a column vector of converted
## numbers, one per row of @var{s}.
##
## @seealso{__hex2bin__}
## @end deftypefn

%!function h = __bin2hex__ (b)
%!  h = dec2hex (bin2dec (b));
%!
%!assert (__bin2hex__ ("1101110"), "6E");
%!xtest assert (__bin2hex__ (["1101110"; "1110"]), ["6E"; "E"]);


## @deftypefn {Function File} {} __hex2bin__ (@var{s}, @var{len})
## Return the binary number corresponding to the hexadecimal number
## stored in the string @var{s}.
##
## If @var{s} is a string matrix, returns a column vector of converted
## numbers, one per row of @var{s}, padded with leading zeros to the
## width of the largest value.
##
## The optional second argument, @var{len}, specifies the minimum
## number of digits in the result.
##
## @seealso{__bin2hex__}
## @end deftypefn

%!function b = __hex2bin__ (h, len)
%!  d = hex2dec (h);
%!
%!  switch nargin
%!    case {1}
%!      b = dec2bin (d);
%!    case {2}
%!      b = dec2bin (d, len);
%!  endswitch
%!
%!assert (__hex2bin__ ("6E"), "1101110");
%!assert (__hex2bin__ (["6E"; "0E"]), ["1101110"; "0001110"]);


## @deftypefn {Function File} {} __bin2num__ (@var{b})
## Return the IEEE 754 double precision number represented by the binary
## number stored in the string @var{b}.
##
## If @var{b} is a string matrix, returns a column vector of converted
## numbers, one per row of @var{b}.
##
## @seealso{__num2bin__}
## @end deftypefn

%!function n = __bin2num__ (b)
%!  n = hex2num (__bin2hex__ (b));
%!
%!assert (__bin2num__ ("0011111111110000000000000000000000000000000000000000000000000000"), 1);
%!assert (__bin2num__ (["0011111111110000000000000000000000000000000000000000000000000000";
%!                      "1100000000001000000000000000000000000000000000000000000000000000"]), [1; -3]);


## @deftypefn {Function File} {} __num2bin__ (@var{n})
## Return the binary representation of the IEEE 754 double precision
## number @var{n}.
##
## If @var{n} is a number matrix, returns a column vector of converted
## numbers, one per row of @var{n}.
##
## @seealso{__bin2num__}
## @end deftypefn

%!function b = __num2bin__ (n)
%!  ## a double precision number is always 64 bits long
%!  b = __hex2bin__ (num2hex (n), 64);
%!
%!assert (__num2bin__ (1),
%!        "0011111111110000000000000000000000000000000000000000000000000000");
%!assert (__num2bin__ ([1; -3]),
%!        ["0011111111110000000000000000000000000000000000000000000000000000";
%!         "1100000000001000000000000000000000000000000000000000000000000000"]);