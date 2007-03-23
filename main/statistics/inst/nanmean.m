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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## v = nanmean(X [, dim]);
## nanmean is identical to the mean function except that NaN values are
## ignored.  If all values are NaN, the mean is returned as NaN. 
## [Is this behaviour compatible?]
##
## See also: nanmin, nanmax, nansum, nanmedian
function v = nanmean (X, varargin) 
  if nargin < 1
    usage ("v = nanmean(X [, dim])");
  else
    n = sum (!isnan(X), varargin{:});
    n(n == 0) = NaN;
    X(isnan(X)) = 0;
    v = sum (X, varargin{:}) ./ n;
  endif
endfunction
