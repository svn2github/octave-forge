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
## @deftypefn {Function File} @var{rstatus} = xlswrite (@var{filename}, @var{arr})
## @deftypefnx {Function File} @var{rstatus} = xlswrite (@var{filename}, @var{arr}, @var{wsh})
## @deftypefnx {Function File} @var{rstatus} = xlswrite (@var{filename}, @var{arr}, @var{wsh}, @var{range})
## @deftypefnx {Function File} @var{rstatus} = xlswrite (@var{filename}, @var{arr}, @var{wsh}, @var{range}, @var{reqintf)
## Add data in 1D/2D array @var{arr} to worksheet @var{wsh} in Excel
## spreadsheet file @var{filename} in range @var{range}.
##
## @var{rstatus} returns 1 if write succeeded, 0 otherwise.
##
## @var{filename} must be a valid .xls Excel file name. If @var{filename}
## does not contain any directory path, the file is saved in the current
## directory.
##
## @var{arr} can be any array type save complex. Mixed numeric/text arrays
## can only be cell arrays.
##
## If only 3 arguments are given, the 3rd is assumed to be a spreadsheet
## range if it contains a ":" or is a completely empty string (corresponding
## to A1:IV65336). The 3rd argument is assumed to refer to a worksheet if
## it is a numeric value or a non-empty text string not containing ":"
##
## @var{wsh} can be a number or string (max. 31 chars).
## In case of a not yet existing Excel file, the first worksheet will be
## used & named according to @var{wsh} - the extra worksheets that Excel
## creates by default are deleted.
## In case of existing files, some checks are made for existing worksheet
## names or numbers, or whether @var{wsh} refers to an existing sheet with
## a type other than worksheet (e.g., chart).
## When new worksheets are to be added to the Excel file, they are
## inserted to the right of all existing worksheets. The pointer to the
## "active" sheet (shown when Excel opens the file) remains untouched.
##
## @var{range} is expected to be a regular spreadsheet range.
## Data is added to the worksheet; existing data in the requested
## range will be overwritten.
## Array @var{arr} will be clipped at the right and/or bottom if its size
## is bigger than can be accommodated in @var{range}.
## If @var{arr} is smaller than the @var{range} allows, it is placed
## in the top left of @var{range}.
##
## If @var{range} contains merged cells, only the elements of @var{arr}
## corresponding to the top or left Excel cells of those merged cells
## will be written, other array cells corresponding to that cell will be
## ignored.
##
## The optional last argument @var{reqintf} can be used to override 
## the automatic selection by xlsread of one interface out of the
## supported ones: COM/Excel, Java/Apache POI, or Java/JExcelAPI.
##
## xlswrite is a mere wrapper for various scripts which find out what
## Excel interface to use (COM, Java/POI) plus code to mimic the other
## brand's syntax. For each call to xlswrite such an interface must be
## started and possibly an Excel file loaded. When writing to multiple
## ranges and/or worksheets in the same Excel file, a speed bonus can be
## obtained by invoking those scripts (xlsopen / octxls / .... / xlsclose)
## directly.
##
## Examples:
##
## @example
##   status = xlswrite ('test4.xls', 'arr', 'Third_sheet', 'C3:AB40');
##   (which adds the contents of array arr (any type) to range C3:AB40 
##   in worksheet 'Third_sheet' in file test4.xls and returns a logical 
##   True (= numerical 1) in status if al went well) 
## @end example
##
## @seealso xlsread, oct2xls, xls2oct, xlsopen, xlsclose, xlsfinfo
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-10-16
## Latest update: 2009-12-11

function [ rstatus ] = xlswrite (filename, arr, arg3, arg4, arg5)

	rstatus = 0;

	# Sanity checks
	if (nargin < 1)
		error ("xlswrite - no Excel filename specified")
		return
	elseif (nargin == 1)
		error ("xlswrite - no data (array) specified")
		return
	elseif (nargin == 2)
		# Assume first worksheet and full worksheet starting at A1
		wsh = 1;
		range = "A1:IV65536";
	elseif (nargin == 3)
		# Find out whether 3rd argument = worksheet or range
		if (isnumeric(arg3) || (isempty(findstr(arg3, ':')) && ~isempty(arg3)))
			# Apparently a worksheet specified
			wsh = arg3;
			range = "A1:IV65536";		# FIXME for OOXML (larger sheet ranges)
		else
			# Range specified
			wsh = 1;
			range = arg3;
		endif
	elseif (nargin >= 4)
		wsh = arg3;
		range = arg4;
	endif
	if (nargin == 5)
		reqintf = arg5;
	else
		reqintf = [];
	endif
	
	# Parse range
	[topleft, nrows, ncols, trow, lcol] = parse_sp_range (range);
	
	# Check if arr fits in range
	[nr, nc] = size (arr);
	if ((nr > nrows) || (nc > ncols))
		# Array too big; truncate
		nr = min(nrows, nr);
		nc = min(ncols, nc);
		warning ("xlswrite - array truncated to %d by %d to fit in range %s", ...
				 nrows, ncols, range);
	endif

	xls = xlsopen (filename, 1, reqintf);

	[xls, rstatus] = oct2xls (arr(1:nr, 1:nc), xls, wsh, topleft);

	xlsclose (xls);

endfunction
