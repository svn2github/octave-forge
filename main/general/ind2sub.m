## Copyright (C) 2001  Paul Kienzle
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

## [ s1, s2, ...] = ind2sub (dims, ind)
## S = ind2sub (dims, ind)
##
## Convert a linear INDex into SUBscripts.  If only one output argument
## is specified, then return a matrix, one column per subscript.
##
## See also: sub2ind

## Author:        Paul Kienzle <pkienzle@kienzle.powernet.co.uk>

function [ ... ] = ind2sub (dims, ind)

  if ( nargin != 2 || all (nargout != [0, 1, length(dims)]) )
    usage ("[s1 s2 ...] = ind2sub (dims, ind) or S = ind2sub (dims, ind)");
  endif

  dims = dims(:);
  n = length(dims);
  power = ones (length(ind), 1) * cumprod ( [1, dims(1:n-1)'] );
  S = ind(:) * ones(1, n) - 1;
  S = floor ( rem (S, dims(1)*power) ./ power ) + 1;

  if nargout <= 1
    vr_val(S);
  else
    for i=1:nargout
      vr_val(S(:,i));
    endfor
  endif

endfunction
