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
## @deftypefn {Function File} {} __num2bin__ (@var{n})
## Return the binary representation of the IEEE 754 double precision number @var{n}.  For example,
##
## @example
## __num2bin__ (1)
##      @result{} 0011111111110000000000000000000000000000000000000000000000000000
## @end example
##
## If @var{n} is a number matrix, returns a column vector of converted numbers, one per row of @var{n}.
##
## @example
## __num2bin__ (["1"; "-3"])
##      @result{} [0011111111110000000000000000000000000000000000000000000000000000; 1100000000001000000000000000000000000000000000000000000000000000]
## @end example
## @seealso{__bin2num__, num2hex, __hex2bin__}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 1.0

function b = __num2bin__ (n)

	b = __hex2bin__ (num2hex (n));

endfunction