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
function y = blkdiag(...),
  nin = 0;
  va_start();
  sizes = zeros( nargin, 2 );
  while( ++nin <= nargin ),
    m = va_arg();
    if ~isnumeric( m ),
      error("Non-numeric argument found.");
    endif
    sizes(nin,:) = size( m );
  endwhile
  csz = [ 0, 0 ; cumsum(sizes) ];
  y = zeros( max(csz) );
  va_start();
  nin = 0;
  while(++nin <= nargin),
    y(csz(nin,1)+1:csz(nin+1,1) , csz(nin,2)+1:csz(nin+1,2)) = va_arg();
  endwhile
endfunction
