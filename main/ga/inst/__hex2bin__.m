## Copyright (C) 2008 Luca Favatella <slackydeb@gmail.com>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program  is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} __hex2bin__ (@var{s}, @var{len})
## Return the binary number corresponding to the hexadecimal number stored in the string @var{s}.  For example,
##
## @example
## __hex2bin__ ("6E")
##      @result{} 1101110
## @end example
##
## If @var{s} is a string matrix, returns a column vector of converted numbers, one per row of @var{s}, padded with leading zeros to the width of the largest value.
##
## @example
## __hex2bin__ (["6E"; "E"])
##      @result{} [1101110; 0001110]
## @end example
##
## The optional third argument, @var{len}, specifies the minimum
## number of digits in the result.

## @seealso{__bin2hex__, hex2dec, dec2bin}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 1.7

function b = __hex2bin__ (h, len)
  d = hex2dec (h);

  switch nargin
    case {1}
      b = dec2bin (d);
    case {2}
      b = dec2bin (d, len);
  endswitch
endfunction

%!assert (__hex2bin__ ("6E"), "1101110")

%!assert (__hex2bin__ (["6E"; "0E"]), ["1101110"; "0001110"])