## Copyright (C) 2001 Laurent Mazet
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

## usage: d = bi2de (b [, p])
##
## convert bit matrix to vector of integers.
##
## p: base of decomposition (default is 2).
##
## d: integer vector.

## 2001-02-02
##   initial release

function d = bi2de (b, p)

  switch (nargin)
    case 1,
      p = 2;
    otherwise
      error ("usage: d = bi2de (b, [p])");
  endswitch

  if ( any (b (:) < 0) || any (b (:) > p - 1) )
    error ("bi2de: d must only contain value in [0, p-1]");
  endif

  if (length (b) == 0)
    d = [];
  else
    d = b * ( p .^ [ 0 : columns(b)-1 ]' );
  endif

endfunction;