## Copyright (C) 2009 Philip Nienhuis <prnienhuis at users.sf.net>
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
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls})
## @deftypefnx {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls}, @var{wsh}, @var{range})
##
## Read data contained within range @var{range} from worksheet @var{wsh}
## in an Excel spreadsheet file pointed to in struct @var{xls}.
##
## xls2oct is a mere wrapper for interface-dependent scripts (e.g.,
## xls2com2oct, xls2jpoi2oct and xls2jxla2oct) that do the actual
## reading.
##
## @var{wsh} is either numerical or text, in the latter case it is 
## case-sensitive and it may be max. 31 characters long.
## Note that in case of a numerical @var{wsh} this number refers to the
## position in the worksheet stack, counted from the left in an Excel
## window. The default is numerical 1, i.e. the leftmost worksheet
## in the Excel file.
##
## @var{range} is expected to be a regular spreadsheet range format,
## or "" (empty string, indicating all data in a worksheet).
##
## If only the first argument is specified, xls2oct will try to read
## all contents from the first = leftmost (or the only) worksheet (as
## if a range of @'' (empty string) was specified).
## 
## If only two arguments are specified, xls2oct assumes the second
## argument to be @var{wsh}. In that case xls2oct will try to read
## all data contained in that worksheet.
##
## Return argument @var{rawarr} contains the raw spreadsheet cell data.
## Optional return argument @var{xls} contains the pointer struct,
## @var{rstatus} will be set to 1 if the requested data have been read
## successfully, 0 otherwise.
## Use parsecell() to separate numeric and text values from @var{rawarr}.
##
## @var{xls} is supposed to have been created earlier by xlsopen in the
## same octave session. It is only referred to, not changed.
##
## If one of the Java interfaces is used, field @var{xls}.limits contains
## the outermost column and row numbers of the actually read cell range.
## This doesn't work with native Excel / COM.
##
## Erroneous data and empty cells turn up empty in @var{rawarr}.
## Date/time values in Excel are returned as numerical values.
## Note that Excel and Octave have different date base values (1/1/1900 & 
## 1/1/0000, resp.)
## Be aware that Excel trims @var{rawarr} from empty outer rows & columns, 
## so any returned cell array may turn out to be smaller than requested
## in @var{range}.
##
## When reading from merged cells, all array elements NOT corresponding 
## to the leftmost or upper Excel cell will be treated as if the
## "corresponding" Excel cells are empty.
##
## Beware: when the COM interface is used, hidden Excel invocations may be
## kept running silently in case of COM errors.
##
## Examples:
##
## @example
##   A = xls2oct (xls1, '2nd_sheet', 'C3:AB40');
##   (which returns the numeric contents in range C3:AB40 in worksheet
##   '2nd_sheet' from a spreadsheet file pointed to in pointer struct xls1,
##   into numeric array A) 
## @end example
##
## @example
##   [An, xls2, status] = xls2oct (xls2, 'Third_sheet');
## @end example
##
## @seealso oct2xls, xlsopen, xlsclose, parsexls, xlsread, xlsfinfo, xlswrite, xls2com2oct, xls2jpoi2oct, xls2jxla2oct 
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-10-16
## Latest update: 2009-12-11

function [ rawarr, xls, rstatus ] = xls2oct (xls, wsh, datrange='')

	if (strcmp (xls.xtype, 'COM'))
		# Call Excel tru COM server
		[rawarr, xls, rstatus] = xls2com2oct (xls, wsh, datrange);
	elseif (strcmp (xls.xtype, 'POI'))
		# Read xls file tru Java POI
		[rawarr, xls, rstatus] = xls2jpoi2oct (xls, wsh, datrange);
	elseif (strcmp (xls.xtype, 'JXL'))
		[rawarr, xls, rstatus] = xls2jxla2oct (xls, wsh, datrange);

#	elseif ---- <Other interfaces here>
	endif

endfunction
