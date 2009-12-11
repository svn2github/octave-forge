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
## @deftypefn {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jpoi2oct (@var{xls})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jpoi2oct (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jpoi2oct (@var{xls}, @var{wsh}, @var{range})
## Get cell contents in @var{range} in worksheet @var{wsh} in an Excel
## file pointed to in struct @var{xls} into the cell array @var{obj}.
## @var{range} can be a range or just the top left cell of the range.
##
## xls2jpoi2oct should not be invoked directly but rather through xls2oct.
##
## Examples:
##
## @example
##   [Arr, status, xls] = xls2jpoi2oct (xls, 'Second_sheet', 'B3:AY41');
##   B = xls2jpoi2oct (xls, 'Second_sheet', 'B3');
## @end example
##
## @seealso xls2oct, oct2xls, xlsopen, xlsclose, xlsread, xlswrite, oct2jpoi2xls
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-11-23
## Last updated 2009-12-11

function [ rawarr, xls, status ] = xls2jpoi2oct (xls, wsh, cellrange=[])

	persistent ctype;
	if (isempty (ctype))
		# Get enumrated cell types. Beware as they start at 0 not 1
		ctype(1) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_NUMERIC');
		ctype(2) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_STRING');
		ctype(3) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_FORMULA');
		ctype(4) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_BLANK');
		ctype(5) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_BOOLEAN');
		ctype(6) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_ERROR');
	endif
	
	status = 0; jerror = 0;
	
	# Check if xls struct pointer seems valid
	test1 = ~isfield (xls, "xtype");
	test1 = test1 || ~isfield (xls, "workbook");
	test1 = test1 || ~strcmp (char (xls.xtype), 'POI');
	test1 = test1 || isempty (xls.workbook);
	test1 = test1 || isempty (xls.app);
	if test1
		error ("Invalid xls file struct");
	else
		wb = xls.workbook;
	endif
	
	# Check if requested worksheet exists in the file & if so, get pointer
	nr_of_sheets = wb.getNumberOfSheets ();
	if (isnumeric (wsh))
		if (wsh > nr_of_sheets), error (sprintf ("Worksheet # %d bigger than nr. of sheets (%d) in file %s", wsh, nr_of_sheets, xls.filename)); endif
		sh = wb.getSheetAt (wsh - 1);			# POI sheet count 0-based
		printf ("(Reading from worksheet %s)\n", 	sh.getSheetName ());
	else
		sh = wb.getSheet (wsh);
		if (isempty (sh)), error (sprintf("Worksheet %s not found in file %s", wsh, xls.filename)); endif
	end

	# Check ranges
	firstrow = sh.getFirstRowNum ();
	lastrow = sh.getLastRowNum ();
	if (isempty (cellrange))
		# Get used range by searching (slow...). Beware, it can be bit unreliable
		lcol = 65535;  # FIXME for OOXML
		rcol = 0;
		for ii=firstrow:lastrow
			irow = sh.getRow (ii);
			if (~isempty (irow))
				scol = (irow.getFirstCellNum).intValue ();
				lcol = min (lcol, scol);
				ecol = (irow.getLastCellNum).intValue () - 1;
				rcol = max (rcol, ecol);
				# Keep track of lowermost non-empty row as getLastRowNum() is unreliable
				if ~(irow.getCell(scol).getCellType () == ctype(4) && irow.getCell(ecol).getCellType () == ctype(4))
					botrow = ii;
				endif
			endif
		endfor
		lastrow = min (lastrow, botrow);
		nrows = lastrow - firstrow + 1;
		ncols = rcol - lcol + 1;
	else
		# Translate range to HSSF POI row & column numbers
		[topleft, nrows, ncols, trow, lcol] = parse_sp_range (cellrange);
		firstrow = max (trow-1, firstrow);
		lastrow = firstrow + nrows - 1;
		lcol = lcol -1;						# POI rows & column # 0-based
	endif
	
	# Create formula evaluator (needed to infer proper cell type into rawarr)
	#         NB formula evaluation is not very reliable in POI
	frm_eval = wb.getCreationHelper().createFormulaEvaluator ();
	
	#wb.clearAllCachedResultsValues();		# does not work
	
	# Read contents into rawarr
	rawarr = cell (nrows, ncols);			# create placeholder
	for ii = firstrow:lastrow
		irow = sh.getRow (ii);
		if ~isempty (irow)
			scol = (irow.getFirstCellNum).intValue ();
			ecol = (irow.getLastCellNum).intValue () - 1;
			for jj = max (scol, lcol) : min (lcol+ncols-1, ecol)
				cell = irow.getCell (jj);
				if ~isempty (cell)
					# Process cell contents
					type_of_cell = cell.getCellType ();
					if (type_of_cell == ctype(3))        # Formula
						try
							cell = frm_eval.evaluate (cell);
							type_of_cell = cell.getCellType();
							switch type_of_cell
								case ctype (1)	# Numeric
									rawarr (ii+1-firstrow, jj+1-lcol) = cell.getNumberValue ();
								case ctype(2)	# String
									rawarr (ii+1-firstrow, jj+1-lcol) = char (cell.getStringValue ());
								case ctype (5)	# Boolean
									rawarr (ii+1-firstrow, jj+1-lcol) = cell.BooleanValue ();
								otherwise
									# Nothing to do here
							endswitch
						catch
							# In case of errors we copy the formula as text into rawarr
							rawarr (ii+1-firstrow, jj+1-lcol) = ["=" cell.getCellFormula];
							type_of_cell = ctype (4);
							if (~jerror) 
								warning ("Java errors in worksheet formulas (converted to string)");
							endif
							++jerror;   # We only need one warning
						end_try_catch
					else
						if (~isnumeric (type_of_cell)) type_of_cell = 4; endif
						switch type_of_cell
						case ctype(1)		# 0 Numeric
							rawarr (ii+1-firstrow, jj+1-lcol) = cell.getNumericCellValue ();
						case ctype(2)		# 1 String
							rawarr (ii+1-firstrow, jj+1-lcol) = char (cell.getRichStringCellValue ());
#						case ctype(3)		# 2 Formula (if still at all needed).
#							try				#  Provisionally we simply take the result
#								rawarr (ii+1-firstrow, jj+1-lcol) = cell.getNumericCellValue ();
#							catch
#								# In case of errors we copy the formula as text into rawarr
#								rawarr (ii+1-firstrow, jj+1-lcol) = ["=" cell.getCellFormula];
#								type_of_cell = ctype (4);
#								if (~jerror) 
#									warning ("Java errors in worksheet formulas (converted to string)");
#								endif
#								++jerror; 
#							end
						case ctype(4)		# 3 Blank
							# Blank; ignore until further notice
						case ctype(5)		# 4 Boolean
							rawarr (ii+1-firstrow, jj+1-lcol) = cell.getBooleanCellValue ();
						otherwise			# 5 Error
							# Error; ignore
						endswitch
					endif
				endif
			endfor
		endif
	endfor

	if (jerror > 0) printf ("%d Java formula evalation errors\n", jerror); endif
	
	# Crop rawarr from empty outer rows & columns like Excel does
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
