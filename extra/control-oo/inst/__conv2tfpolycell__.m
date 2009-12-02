## Copyright (C) 2009   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## Convert a (cell of) row vector(s) to a cell of tfpoly objects.
## Used by tf and __set__.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2009
## Version: 0.1

function ndr = __conv2tfpolycell__ (nd)

  if (! iscell (nd))
    nd = {nd};
  endif

  [ndrows, ndcols] = size (nd);

  ndr = cell (ndrows, ndcols);

  for k = 1 : ndrows
    for l = 1 : ndcols
      ndr{k, l} = tfpoly (nd{k, l});
    endfor
  endfor

endfunction