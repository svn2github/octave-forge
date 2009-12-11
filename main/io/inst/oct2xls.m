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
## @deftypefn {Function File} [ @var{xls}, @var{rstatus} ] = oct2xls (@var{arr}, @var{xls})
## @deftypefnx {Function File} [ @var{xls}, @var{rstatus} ] = oct2xls (@var{arr}, @var{xls}, @var{wsh})
## @deftypefnx {Function File} [ @var{xls}, @var{rstatus} ] = oct2xls (@var{arr}, @var{xls}, @var{wsh}, @var{topleft})
##
## Add data in 1D/2D CELL array @var{arr} into a range with upper left
## cell equal to @var{topleft} in worksheet @var{wsh} in an Excel
## spreadsheet file pointed to in structure @var{range}.
## Return argument @var{xlso} equals supplied argument @var{xlsi} and is
## updated by oct2xls.
##
## oct2xls is a mere wrapper for interface-dependent scripts (e.g., 
## oct2com2xls, oct2jpoi2xls, oct2jxla2xls) that do the actual writing to
## spreadsheet files.
##
## A subsequent call to xlsclose is needed to write the updated spreadsheet
## to disk (and -if needed- close the Excel or Java invocation).
##
## @var{arr} can be any array type save complex. Mixed numeric/text arrays
## can only be cell arrays.
##
## @var{xls} must be a valid pointer struct created earlier by xlsopen.
##
## @var{wsh} can be a number or string (max. 31 chars).
## In case of a yet non-existing Excel file, the first worksheet will be
## used & named according to @var{wsh} - the extra worksheets that Excel
## creates by default are deleted.
## In case of existing files, some checks are made for existing worksheet
## names or numbers, or whether @var{wsh} refers to an existing sheet with
## a type other than worksheet (e.g., chart).
## When new worksheets are to be added to the Excel file, they are
## inserted to the right of all existing worksheets. The pointer to the
## "active" sheet (shown when Excel opens the file) remains untouched.
##
## If omitted, @var{topleft} is supposed to be 'A1'. The actual range to
## be used is determined by the size of @var{arr}.
##
## Data are added to the worksheet, ignoring other data already present;
## existing data in the range to be used will be overwritten.
##
## If @var{range} contains merged cells, only the elements of @var{arr}
## corresponding to the top or left Excel cells of those merged cells
## will be written, other array cells corresponding to that cell will be
## ignored.
##
## Beware that -if invoked- Excel invocations may be left running silently
## in case of COM errors. Invoke xlsclose with proper pointer struct to
## close them.
##
## Examples:
##
## @example
##   [xlso, status] = xls2oct ('arr', xlsi, 'Third_sheet', 'AA31');
## @end example
##
## @seealso xls2oct, xlsopen, xlsclose, xlsread, xlswrite, oct2com2xls, oct2jpoi2xls, oct2jxla2xls
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-01
## Latest update: 2009-12-11

function [ xls, rstatus ] = oct2xls (obj, xls, wsh, topleft='A1')

	if (isnumeric (obj))
		obj = num2cell (obj);
	elseif (ischar (obj))
		obj = {obj};
	endif

	if (strcmp (xls.xtype, 'COM'))
		# Call oct2com2xls to do the work
		[xls, rstatus] = oct2com2xls (obj, xls, wsh, topleft);

	elseif (strcmp (xls.xtype, 'POI'))
		# Invoke Java and Apache POI
		[xls, rstatus] = oct2jpoi2xls (obj, xls, wsh, topleft);

	elseif (strcmp (xls.xtype, 'JXL'))
		# Invoke Java and JExcelAPI
		[xls, rstatus] = oct2jxla2xls (obj, xls, wsh, topleft);

#	elseif (strcmp'xls.xtype, '<whatever>'))
#		<Other Excel interfaces>

	endif

endfunction
