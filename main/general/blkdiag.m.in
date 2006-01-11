## Copyright (C) 2000 Daniel Calvelo
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

## Build a block-diagonal matrix from all the arguments

## Author: Daniel Calvelo
function y = blkdiag(varargin)
  sizes = zeros (nargin, 2);
  for i=1:nargin
    m = varargin{i};
    if ~isnumeric (m),
      error ("Non-numeric argument found.");
    endif
    sizes (i, :) = size (m);
  endfor
  csz = [ 0, 0 ; cumsum(sizes) ];
  y = zeros (csz (rows (csz), :));
  for i=1:nargin
    y (csz(i,1)+1:csz(i+1,1) , csz(i,2)+1:csz(i+1,2)) = varargin{i};
  endfor
endfunction

%!assert(blkdiag(1,ones(2),1),[1,0,0,0;0,1,1,0;0,1,1,0;0,0,0,1])

