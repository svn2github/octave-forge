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
## Created: 2010-10-16
## Latest update: 2009-01-03 (added OOXML support & cleaned up code. Excel 
##                            INDIRECT function still not working OK)

function [ rawarr, xls, rstatus ] = xls2oct (xls, wsh, datrange='')

	if (strcmp (xls.xtype, 'COM'))
		# Call Excel tru COM server
		[rawarr, xls, rstatus] = xls2com2oct (xls, wsh, datrange);
	elseif (strcmp (xls.xtype, 'POI'))
		# Read xls file tru Java POI
		[rawarr, xls, rstatus] = xls2jpoi2oct (xls, wsh, datrange);
	elseif (strcmp (xls.xtype, 'JXL'))
		# Read xls file tru JExcelAPI
		[rawarr, xls, rstatus] = xls2jxla2oct (xls, wsh, datrange);

#	elseif ---- <Other interfaces here>

	else
		error (sprintf ("xls2oct: unknown Excel .xls interface - %s.", xls.xtype));

	endif

endfunction


#====================================================================================
## Copyright (C)2009 P.R. Nienhuis, <pr.nienhuis at hccnet.nl>
##
## based on mat2xls by Michael Goffioul (2007) <michael.goffioul@swing.be>
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2com2oct (@var{xls})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2com2oct (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2com2oct (@var{xls}, @var{wsh}, @var{range})
## Get cell contents in @var{range} in worksheet @var{wsh} in an Excel
## file pointed to in struct @var{xls} into the cell array @var{obj}. 
##
## xls2com2oct should not be invoked directly but rather through xls2oct.
##
## Examples:
##
## @example
##   [Arr, status, xls] = xls2com2oct (xls, 'Second_sheet', 'B3:AY41');
##   Arr = xls2com2oct (xls, 'Second_sheet');
## @end example
##
## @seealso xls2oct, oct2xls, xlsopen, xlsclose, xlsread, xlswrite
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-09-23
## Last updated 2009-12-11

function [obj, xls, rstatus ] = xls2com2oct (xls, wsh, range)

	rstatus = 0; obj = {};
  
	# Basic checks
	if (nargin < 2) error ("xls2com2oct needs a minimum of 2 arguments."); endif
	if (size (wsh, 2) > 31) 
		warning ("Worksheet name too long - truncated") 
		wsh = wsh(1:31);
	endif

	nrows = 0;
	emptyrange = 0;
	if ((nargin == 2) || (isempty (range))) 
		emptyrange = 1;
	else
		# Extract top_left_cell from range
		[topleft, nrows, ncols] = parse_sp_range (range);
	endif;
  
	if (nrows >= 1 || emptyrange) 
		# Check the file handle struct
		test1 = ~isfield (xls, "xtype");
		test1 = test1 || ~isfield (xls, "workbook");
		test1 = test1 || ~strcmp (char (xls.xtype), 'COM');
		test1 = test1 || isempty (xls.workbook);
		test1 = test1 || isempty (xls.app);
		if test1
			error ("Invalid file pointer struct");
		endif
		app = xls.app;
		wb = xls.workbook;
		wb_cnt = wb.Worksheets.count;
		old_sh = 0;	
		if (isnumeric (wsh))
			if (wsh < 1 || wsh > wb_cnt)
				errstr = sprintf ("Worksheet number: %d out of range 1-%d", wsh, wb_cnt);
				error (errstr)
				return
			else
				old_sh = wsh;
			endif
		else
			# Find worksheet number corresponding to name in wsh
			wb_cnt = wb.Worksheets.count;
			for ii =1:wb_cnt
				sh_name = wb.Worksheets(ii).name;
				if (strcmp (sh_name, wsh)) old_sh = ii; endif
			endfor
			if (~old_sh)
				errstr = sprintf ("Worksheet name \"%s\" not present", wsh);
				error (errstr)
			else
				wsh = old_sh;
			endif
		endif

		sh = wb.Worksheets (wsh);
		
		if (emptyrange)
		   allcells = sh.UsedRange;
		   obj = allcells.Value;
		else
			# Get object from Excel sheet, starting at cell top_left_cell
			r = sh.Range (topleft);
			r = r.Resize (nrows, ncols);
			obj = r.Value;
			delete (r);
		endif;
		# Take care of actual singe cell range
		if (isnumeric (obj) || ischar (obj))
			obj = {obj};
		endif
		# If we get here, all seems to have gone OK
		rstatus = 1;
	
  else
    error ("No data read from Excel file");
	rstatus = 0;
	
  endif
	
endfunction


#==================================================================================
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
						case ctype(4)		# 3 Blank
							# Blank; ignore until further notice
						case ctype(5)		# 4 Boolean
							rawarr (ii+1-firstrow, jj+1-lcol) = cell.getBooleanCellValue ();
						otherwise			# 5 Error
							# Formula (treated above) or error; ignore
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


#==================================================================================
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

