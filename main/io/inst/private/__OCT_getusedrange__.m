## Copyright (C) 2013 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} __OCT_getusedrange__ (@var{x} @var{y})
## Get leftmost & rightmost occupied column numbers, and topmost and
## lowermost occupied row numbers (base 1).
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2013-09-08
## Updates:
## 2013-09-23 Prepared for adding in OOXML
## 2013-09-26 Improved code to skip last empty columns in column count
## 2013-09-27 Re-use old jOpenDocument code; may be slow but it is well-tested

function [ trow, brow, lcol, rcol ] = __OCT_getusedrange__ (spptr, ii)

  if (strcmpi (spptr.filename(end-3:end), ".ods"))
    [ trow, brow, lcol, rcol ] = __OCT_ods_getusedrange__ (spptr, ii);
  else
    [ trow, brow, lcol, rcol ] = __OCT_xlsx_getusedrange__ (spptr, ii);
  endif

endfunction


##=============================OOXML========================
function [ trow, brow, lcol, rcol ] = __OCT_xlsx_getusedrange__ (spptr, ii);

  trow = brow = lcol = rcol = 0;

  ## FIXME OOXML stuff (.xlsx) here

endfunction


##==============================ODS=========================
function [ trow, brow, lcol, rcol ] = __OCT_ods_getusedrange__ (spptr, ii)

  trow = brow = lcol = rcol = nrows = ncols = 0;

  ## Check input
  nsheets = numel (spptr.sheets.sh_names); 
  if (ii > nsheets)
    error ("getusedrange: sheet index (%d) out of range (1 - %d)", ii, nsheets);
  endif

  ## Get requested sheet from info in ods struct pointer
  sheet = spptr.workbook(spptr.sheets.shtidx(ii):spptr.sheets.shtidx(ii+1)-1);

  ## Check if sheet contains any cell content at all
  ## FIXME: in far-fetched cases, cell string content may contain ' office:value' too
  if (isempty (strfind (sheet, " office:value")))
    return
  endif

  [trow, brow, lcol, rcol ] = __ods_get_sheet_dims__ (sheet);

endfunction
