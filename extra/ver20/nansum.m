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

## v = nansum (X [, dim]);
## nansum is identical to the sum function except that NaN values are
## treated as 0 and so ignored.  If all values are NaN, the sum is 
## returned as 0. [Is this behaviour compatible?]
##
## See also: nanmin, nanmax, nanmean, nanmedian
function v = nansum (X, ...)
  if nargin < 1
    usage ("v = nansum (X [, dim])");
  else
    dfi = do_fortran_indexing;
    pzoi = prefer_zero_one_indexing;
    unwind_protect
      do_fortran_indexing = 1;
      prefer_zero_one_indexing = 1;

      X(isnan(X)) = 0;
      v = sum (X, all_va_args);
    unwind_protect_cleanup
      do_fortran_indexing = dfi;
      prefer_zero_one_indexing = pzoi;
    end_unwind_protect
  endif
endfunction
