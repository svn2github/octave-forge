## Copyright (C) 2001 Paul Kienzle
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

## qidx = quantiz(x, table)
##   Determine position of x in strictly monotonic table.  The first
##   interval, using index 0, corresponds to x <= table(1).
##   Subsequent intervals are table(i-1) < x <= table(i).
##
## [qidx, q] = quantiz(x, table, codes)
##   Associate each interval of the table with a code.  Use codes(1) 
##   for x <= table(1) and codes(n+1) for table(n) < x <= table(n+1).
##
## [qidx, q, d] = quantiz(...)
##   Compute distortion as mean squared distance of x from the
##   corresponding table positions.  Note that an equally valid
##   definition of distortion is the distance from the codebook
##   values.
function [qidx, q, d] = quantiz (x, table, codes)
  if (nargin < 2 || nargin > 3)
    usage("[qidx, q, d] = quantiz(x, table, codes)");
  endif

  qidx = length(table) - lookup(flipud(table(:)), x);
  if (nargin > 2 && nargout > 1)
    q = codes(qidx + 1);
  endif
  if (nargout > 2)
    warning("distortion is relative to table instead of codes");
    table = [table(1) ; table(:) ];
    d = sumsq (x(:) - table(qidx+1)) / length(x);
  endif
endfunction
