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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## [v, idx] = nanmax(X [, dim]);
## nanmax is identical to the max function except that NaN values are
## treated as -Inf, and so are ignored.  If all values are NaN, the
## maximum is returned as -Inf. [Is this behaviour compatible?]
##
## See also: nansum, nanmin, nanmean, nanmedian
function [v, idx] = nanmax (X, ...)
  if nargin < 1
    usage ("[v, idx] = nanmax(X [, dim])");
  else
    nanvals = isnan(X);
    X(nanvals) = -Inf;
    [v,idx] = max (X, all_va_args);
    v(all(nanvals, all_va_args)) = NaN;
  endif
endfunction
