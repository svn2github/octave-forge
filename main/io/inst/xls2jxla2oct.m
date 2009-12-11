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
## @deftypefn {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jxla2oct (@var{xls})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jxla2oct (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jxla2oct (@var{xls}, @var{wsh}, @var{range})
## Get cell contents in @var{range} in worksheet @var{wsh} in an Excel
## file pointed to in struct @var{xls} into the cell array @var{obj}.
## @var{range} can be a range or just the top left cell of the range.
##
## xls2jxla2oct should not be invoked directly but rather through xls2oct.
##
## Examples:
##
## @example
##   [Arr, status, xls] = xls2jxla2oct (xls, 'Second_sheet', 'B3:AY41');
##   B = xls2jxla2oct (xls, 'Second_sheet');
## @end example
##
## @seealso xls2oct, oct2xls, xlsopen, xlsclose, xlsread, xlswrite, oct2jxla2xls
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-04
## Last updated 2009-12-11

function [ rawarr, xls, status ] = xls2jxla2oct (xls, wsh, cellrange=[])

	persistent ctype;
	if (isempty (ctype))
		ctype = cell (11, 1);
		# Get enumerated cell types. Beware as they start at 0 not 1
		ctype(1,1) = (java_get ('jxl.CellType', 'BOOLEAN')).toString ();
		ctype(2,1) = (java_get ('jxl.CellType', 'BOOLEAN_FORMULA')).toString ();
		ctype(3,1) = (java_get ('jxl.CellType', 'DATE')).toString ();
		ctype(4,1) = (java_get ('jxl.CellType', 'DATE_FORMULA')).toString ();
		ctype(5,1) = (java_get ('jxl.CellType', 'EMPTY')).toString ();
		ctype(6,1) = (java_get ('jxl.CellType', 'ERROR')).toString ();
		ctype(7,1) = (java_get ('jxl.CellType', 'FORMULA_ERROR')).toString ();
		ctype(8,1) = (java_get ('jxl.CellType', 'NUMBER')).toString ();
		ctype(9,1) = (java_get ('jxl.CellType', 'LABEL')).toString ();
		ctype(10,1) = (java_get ('jxl.CellType', 'NUMBER_FORMULA')).toString ();
		ctype(11,1) = (java_get ('jxl.CellType', 'STRING_FORMULA')).toString ();
	endif
	
	status = 0;
	
	# Check if xls struct pointer seems valid
	test1 = ~isfield (xls, "xtype");
	test1 = test1 || ~isfield (xls, "workbook");
	test1 = test1 || ~strcmp (char (xls.xtype), 'JXL');
	test1 = test1 || isempty (xls.workbook);
	test1 = test1 || isempty (xls.app);
	if test1
		error ("Invalid xls file struct");
	else
		wb = xls.workbook;
	endif
	
	# Check if requested worksheet exists in the file & if so, get pointer
	nr_of_sheets = wb.getNumberOfSheets ();
	shnames = char (wb.getSheetNames ());
	if (isnumeric (wsh))
		if (wsh > nr_of_sheets), error (sprintf ("Worksheet # %d bigger than nr. of sheets (%d) in file %s", wsh, nr_of_sheets, xls.filename)); endif
		sh = wb.getSheet (wsh - 1);			# POI sheet count 0-based
		printf ("(Reading from worksheet %s)\n", shnames {wsh});
	else
		sh = wb.getSheet (wsh);
		if (isempty (sh)), error (sprintf ("Worksheet %s not found in file %s", wsh, xls.filename)); endif
	end

	# Check ranges
	firstrow = 0;
	lcol = 0;
	
	if (isempty (cellrange))
		nrows = sh.getRows ();
		lastrow = nrows - 1;
		ncols = sh.getColumns ();
		trow = firstrow;
		rcol = ncols - 1;
	else
		# Translate range to HSSF POI row & column numbers
		[dummy, nrows, ncols, trow, lcol] = parse_sp_range (cellrange);
		firstrow = max (trow-1, firstrow);
		lastrow = firstrow + nrows - 1;
		lcol = lcol - 1;					# POI rows & column # 0-based
	endif

	# Read contents into rawarr
	rawarr = cell (nrows, ncols);			# create placeholder
	for jj = lcol : lcol+ncols-1
		for ii = firstrow:lastrow
			cell = sh.getCell (jj, ii);
			type_of_cell = char (cell.getType ());
			switch type_of_cell
				case ctype {1, 1}
					# Boolean
					rawarr (ii+1-firstrow, jj+1-lcol) = cell.getValue ();
				case ctype {2, 1}
					# Boolean formula
					rawarr (ii+1-firstrow, jj+1-lcol) = cell.getValue ();
				case ctype {3, 1}
					# Date
					rawarr (ii+1-firstrow, jj+1-lcol) = cell.getValue ();
				case ctype {4, 1}
					# Date Formula
					rawarr (ii+1-firstrow, jj+1-lcol) = cell.getValue ();
				case ctype {5, 1}
					# Empty. Nothing to do here
				case ctype {6, 1}
					# Error. Nothing to do here
				case ctype {7, 1}
					# Formula Error. Nothing to do here
				case ctype {8, 1}
					# Number
					rawarr (ii+1-firstrow, jj+1-lcol) = cell.getValue ();
				case ctype {9, 1}
					# String
					rawarr (ii+1-firstrow, jj+1-lcol) = cell.getString ();
				case ctype {10, 1}
					# NumericalFormula
					rawarr (ii+1-firstrow, jj+1-lcol) = cell.getValue ();
				case ctype {11, 1}
					# String Formula
					rawarr (ii+1-firstrow, jj+1-lcol) = cell.getString ();
			endswitch
		endfor
	endfor

	# Crop rawarr from empty outer rows & columns just like Excel does
	emptr = cellfun('isempty', rawarr);
	irowt = 1;
	while (all (emptr(irowt, :))), irowt++; endwhile
	irowb = nrows;
	while (all (emptr(irowb, :))), irowb--; endwhile
	icoll = 1;
	while (all (emptr(:, icoll))), icoll++; endwhile
	icolr = ncols;
	while (all (emptr(:, icolr))), icolr--; endwhile
	# Crop textarray
	rawarr = rawarr(irowt:irowb, icoll:icolr);
	status = 1;

	xls.limits = [lcol+icoll, lcol+icolr; firstrow+irowt, firstrow+irowb];
	
endfunction
