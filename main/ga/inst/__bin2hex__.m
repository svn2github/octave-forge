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
## @deftypefn {Function File} {} __bin2hex__ (@var{s})
## Return the hexadecimal number corresponding to the binary number stored in the string @var{s}.  For example,
##
## @example
## __bin2hex__ ("1101110")
##      @result{} 6E
## @end example
##
## If @var{s} is a string matrix, returns a column vector of converted numbers, one per row of @var{s}.
##
## @example
## __bin2hex__ (["1101110"; "1110"])
##      @result{} [6E; 0E]
## @end example
## @seealso{__hex2bin__, bin2dec, dec2hex}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 1.1

function h = __bin2hex__ (b)

	h = dec2hex (bin2dec (b));

endfunction