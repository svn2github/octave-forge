## Copyright (C) 1999 Peter Ekberg
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## usage: rosser
##
## Return the Rosser matrix.
##
## See also: hankel, vander, sylvester_matrix, hilb, invhilb, toeplitz
##           hadamard, wilkinson, compan, pascal

## Author: Peter Ekberg
##         (peda)

function retval = rosser

  if (nargin != 0)
    usage ("rosser");
  endif

  retval = [
    611,   196,  -192,   407,    -8,   -52,   -49,    29;
    196,   899,   113,  -192,   -71,   -43,    -8,   -44;
   -192,   113,   899,   196,    61,    49,     8,    52;
    407,  -192,   196,   611,     8,    44,    59,   -23;
     -8,   -71,    61,     8,   411,  -599,   208,   208;
    -52,   -43,    49,    44,  -599,   411,   208,   208;
    -49,    -8,     8,    59,   208,   208,    99,  -911;
     29,   -44,    52,   -23,   208,   208,  -911,    99; ];
endfunction
