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

## [v, idx] = nanmin (X [, dim]);
## nanmin is identical to the min function except that NaN values are
## treated as Inf, and so are ignored.  If all values are NaN, the
## minimum is returned as Inf. [Is this behaviour compatible?]
##
## See also: nansum, nanmax, nanmean, nanmedian
function [v, idx] = nanmin (X, varargin)
  if nargin < 1
    usage ("[v, idx] = nanmin (X [, dim])");
  else
    try dfi = do_fortran_indexing;
    catch dfi = 0;
    end
    try wfi = warn_fortran_indexing;
    catch wfi = 0;
    end
    try pzoi = prefer_zero_one_indexing;
    catch pzoi = 0;
    end
    unwind_protect
      do_fortran_indexing = 1;
      warn_fortran_indexing = 0;
      prefer_zero_one_indexing = 1;

      X(isnan(X)) = Inf;
      [v, idx] = min (X, varargin{:});
    unwind_protect_cleanup
      do_fortran_indexing = dfi;
      warn_fortran_indexing = wfi;
      prefer_zero_one_indexing = pzoi;
    end_unwind_protect
  endif
endfunction
