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
## @deftypefn {Function File} {} __bin2num__ (@var{b})
## Return the IEEE 754 double precision number represented by the binary number stored in the string @var{b}.  For example,
##
## @example
## __bin2num__ ("0011111111110000000000000000000000000000000000000000000000000000")
##      @result{} 1
## @end example
##
## If @var{b} is a string matrix, returns a column vector of converted numbers, one per row of @var{b}.
##
## @example
## __bin2num__ (["0011111111110000000000000000000000000000000000000000000000000000"; "1100000000001000000000000000000000000000000000000000000000000000"])
##      @result{} [1; -3]
## @end example
## @seealso{__num2bin__, __bin2hex__, hex2num}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 1.0

function n = __bin2num__ (b)

	n = hex2num (__bin2hex__ (b));

endfunction