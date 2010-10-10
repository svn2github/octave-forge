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
## @deftypefnx {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls}, @var{wsh}, @var{range}, @var{options})
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
## If no range is specified the occupied cell range will have to be
## determined behind the scenes first; this can take some time for the
## Java-based interfaces. Be aware that in Excel/ActiveX interface the
## used range can be outdated. The Java-based interfaces are more 
## reliable in this respect albeit much slower.
##
## Optional argument @var{options}, a structure, can be used to
## specify various read modes. Currently the only option field is
## "formulas_as_text"; if set to TRUE or 1, spreadsheet formulas
## (if at all present) are read as formula strings rather than the
## evaluated formula result values. This only works for the Java
## based interfaces (POI and JXL).
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
## When using COM or POI interface, formulas in cells are evaluated; if
## that fails cached values are retrieved. These may be outdated 
## depending on Excel's "Automatic calculation" settings when the
## spreadsheet was saved.
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
## @seealso oct2xls, xlsopen, xlsclose, parsecell, xlsread, xlsfinfo, xlswrite 
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2010-10-16
## Updates: 
## 2009-01-03 (added OOXML support & cleaned up code. Excel 
##             ADDRESS function still not working OK)
## 2010-03-14 Updated help text
## 2010-05-31 Updated help text (delay i.c.o. empty range due to getusedrange call)
## 2010-07-28 Added option to read formulas as text strings rather than evaluated value
## 2010-08-25 Small typo in help text
##
## Latest subfunc update: 2010-10-08 (xls2com2oct)

function [ rawarr, xls, rstatus ] = xls2oct (xls, wsh, datrange='', spsh_opts=[])

	# Check & setup options struct
	if (nargin < 4 || isempty (spsh_opts))
		spsh_opts.formulas_as_text = 0;
		spsh_opts.strip_array = 1;
		# Future options:
	endif

	# Select the proper interfaces
	if (strcmp (xls.xtype, 'COM'))
		# Call Excel tru COM server. Excel/COM has no way of returning formulas
		# as strings, so arg spsh_opts has no use (yet)
		[rawarr, xls, rstatus] = xls2com2oct (xls, wsh, datrange);
	elseif (strcmp (xls.xtype, 'POI'))
		# Read xls file tru Java POI
		[rawarr, xls, rstatus] = xls2jpoi2oct (xls, wsh, datrange, spsh_opts);
	elseif (strcmp (xls.xtype, 'JXL'))
		# Read xls file tru JExcelAPI
		[rawarr, xls, rstatus] = xls2jxla2oct (xls, wsh, datrange, spsh_opts);
#	elseif ---- <Other interfaces here>
		# Call to next interface
	else
		error (sprintf ("xls2oct: unknown Excel .xls interface - %s.", xls.xtype));
	endif

	# Optionally strip empty outer rows and columns & keep track of original data location
	if (spsh_opts.strip_array)
		emptr = cellfun ('isempty', rawarr);
		if (all (all (emptr)))
			rawarr = {};
			xls.limits = [];
		else
			nrows = size (rawarr, 1); ncols = size (rawarr, 2);
			irowt = 1;
			while (all (emptr(irowt, :))), irowt++; endwhile
			irowb = nrows;
			while (all (emptr(irowb, :))), irowb--; endwhile
			icoll = 1;
			while (all (emptr(:, icoll))), icoll++; endwhile
			icolr = ncols;
			while (all (emptr(:, icolr))), icolr--; endwhile

			# Crop output cell array and update limits
			rawarr = rawarr(irowt:irowb, icoll:icolr);
			xls.limits = xls.limits + [icoll-1, icolr-ncols; irowt-1, irowb-nrows];
		endif
	endif

endfunction


#====================================================================================
## Copyright (C) 2009 P.R. Nienhuis, <pr.nienhuis at hccnet.nl>
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
## Last updates:
## 2009-12-11 <forgot what it was>
## 2010-10-07 Implemented limits (only reliable for empty input ranges)
## 2010-10-08 Resulting data array now cropped (also in case of specified range)
## 2010-10-10 More code cleanup (shuffled xls tests & wsh ptr code before range checks)

function [rawarr, xls, rstatus ] = xls2com2oct (xls, wsh, crange)

	rstatus = 0; rawarr = {};
  
	# Basic checks
	if (nargin < 2) error ("xls2com2oct needs a minimum of 2 arguments."); endif
	if (size (wsh, 2) > 31) 
		warning ("Worksheet name too long - truncated") 
		wsh = wsh(1:31);
	endif

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

	# Check & get handle to requested worksheet
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

	nrows = 0;
	if ((nargin == 2) || (isempty (crange)))
		allcells = sh.UsedRange;
		# Get actually used range indices
		[trow, brow, lcol, rcol] = getusedrange (xls, old_sh);
		nrows = brow - trow + 1; ncols = rcol - lcol + 1;
		topleft = calccelladdress (trow, lcol);
	else
		# Extract top_left_cell from range
		[topleft, nrows, ncols, trow, lcol] = parse_sp_range (crange);
		brow = trow + nrows - 1;
		rcol = lcol + ncols - 1;
	endif;
  
	if (nrows >= 1) 
		# Get object from Excel sheet, starting at cell top_left_cell
		r = sh.Range (topleft);
		r = r.Resize (nrows, ncols);
		rawarr = r.Value;
		delete (r);

		# Take care of actual singe cell range
		if (isnumeric (rawarr) || ischar (rawarr))
			rawarr = {rawarr};
		endif

		# If we get here, all seems to have gone OK
		rstatus = 1;
		# Keep track of data rectangle limits
		xls.limits = [lcol, rcol; trow, brow];
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
## Updates: 
## 2010-01-11 Fall back to cached values when formula evaluator fails
## 2010-03-14 Fixed max column nr for OOXML for empty given range
## 2010-07-28 Added option to read formulas as text strings rather than evaluated value
## 2010-08-01 Some bug fixes for formula reading (cvalue rather than scell)
## 2010-10-10 Code cleanup: -getusedrange called; - fixed typo in formula evaluation msg;
##      "     moved cropping output array to calling function.

function [ rawarr, xls, status ] = xls2jpoi2oct (xls, wsh, cellrange=[], spsh_opts)

	persistent ctype;
	if (isempty (ctype))
		# Get enumerated cell types. Beware as they start at 0 not 1
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
		if (isempty (sh)), error (sprintf ("Worksheet %s not found in file %s", wsh, xls.filename)); endif
	end

	# Check ranges
	firstrow = sh.getFirstRowNum ();		# 0-based
	lastrow = sh.getLastRowNum ();			# 0-based
	if (isempty (cellrange))
#		# Get used range by searching (slow...). Beware, it can be bit unreliable
#		## FIXME - can be replaced by call to getusedrange.m
#		lcol = 65535;    # Old xls value
#		lcol = 1048576;  # OOXML (xlsx) max.
#		rcol = 0;
#		for ii=firstrow:lastrow
#			irow = sh.getRow (ii);
#			if (~isempty (irow))
#				scol = (irow.getFirstCellNum).intValue ();
#				lcol = min (lcol, scol);
#				ecol = (irow.getLastCellNum).intValue () - 1;
#				rcol = max (rcol, ecol);
#				# Keep track of lowermost non-empty row as getLastRowNum() is unreliable
#				if ~(irow.getCell(scol).getCellType () == ctype(4) && irow.getCell(ecol).getCellType () == ctype(4))
#					botrow = ii;
#				endif
#			endif
#		endfor
		if (ischar (wsh))
			# get numeric sheet index
			ii = wb.getSheetIndex (sh);
		else
			ii = wsh;
		endif
		[ firstrow, lastrow, lcol, rcol ] = getusedrange (xls, ii);
		nrows = lastrow - firstrow + 1;
		ncols = rcol - lcol + 1;
	else
		# Translate range to HSSF POI row & column numbers
		[topleft, nrows, ncols, firstrow, lcol] = parse_sp_range (cellrange);
		lastrow = firstrow + nrows - 1;
		rcol = lcol + ncols - 1;
	endif

	# Create formula evaluator (needed to infer proper cell type into rawarr)
	frm_eval = wb.getCreationHelper().createFormulaEvaluator ();
	
	# Read contents into rawarr
	rawarr = cell (nrows, ncols);			# create placeholder
	for ii = firstrow:lastrow
		irow = sh.getRow (ii-1);
		if ~isempty (irow)
			scol = (irow.getFirstCellNum).intValue ();
			ecol = (irow.getLastCellNum).intValue () - 1;
			for jj = lcol:rcol
				scell = irow.getCell (jj-1);
				if ~isempty (scell)
					# Explore cell contents
					type_of_cell = scell.getCellType ();
					if (type_of_cell == ctype(3))        # Formula
						if ~(spsh_opts.formulas_as_text)
							try		# Because not al Excel formulas have been implemented
								cvalue = frm_eval.evaluate (scell);
								type_of_cell = cvalue.getCellType();
								# Separate switch because form.eval. yields different type
								switch type_of_cell
									case ctype (1)	# Numeric
										rawarr (ii+1-firstrow, jj+1-lcol) = scell.getNumberValue ();
									case ctype(2)	# String
										rawarr (ii+1-firstrow, jj+1-lcol) = char (scell.getStringValue ());
									case ctype (5)	# Boolean
										rawarr (ii+1-firstrow, jj+1-lcol) = scell.BooleanValue ();
									otherwise
										# Nothing to do here
								endswitch
								# Set cell type to blank to skip switch below
								type_of_cell = ctype(4);
							catch
								# In case of formula errors we take the cached results
								type_of_cell = scell.getCachedFormulaResultType ();
								++jerror;   # We only need one warning even for multiple errors 
							end_try_catch
						endif
					endif
					# Preparations done, get data values into data array
					switch type_of_cell
						case ctype(1)		# 0 Numeric
							rawarr (ii+1-firstrow, jj+1-lcol) = scell.getNumericCellValue ();
						case ctype(2)		# 1 String
							rawarr (ii+1-firstrow, jj+1-lcol) = char (scell.getRichStringCellValue ());
						case ctype(3)
							if (spsh_opts.formulas_as_text)
								tmp = char (scell.getCellFormula ());
								rawarr (ii+1-firstrow, jj+1-lcol) = ['=' tmp];
							endif
						case ctype(4)		# 3 Blank
							# Blank; ignore until further notice
						case ctype(5)		# 4 Boolean
							rawarr (ii+1-firstrow, jj+1-lcol) = scell.getBooleanCellValue ();
						otherwise			# 5 Error
							# Ignore
					endswitch
				endif
			endfor
		endif
	endfor

	if (jerror > 0) warning (sprintf ("xls2oct: %d cached values instead of formula evaluations.\n", jerror)); endif
	
#	# Crop rawarr from empty outer rows & columns
#	emptr = cellfun('isempty', rawarr);
#	irowt = 1;
#	while (all (emptr(irowt, :))), irowt++; endwhile
#	irowb = nrows;
#	while (all (emptr(irowb, :))), irowb--; endwhile
#	icoll = 1;
#	while (all (emptr(:, icoll))), icoll++; endwhile
#	icolr = ncols;
#	while (all (emptr(:, icolr))), icolr--; endwhile
#	# Crop cell array
#	rawarr = rawarr(irowt:irowb, icoll:icolr);
	status = 1;

	xls.limits = [lcol, rcol; firstrow, lastrow];
	
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
## Updates:
## 2009-12-11 ??? some bug fix
## 2010-07-28 Added option to read formulas as text strings rather than evaluated value
##            Added check for proper xls structure
## 2010-07-29 Added check for too latge requested data rectangle
## 2010-10-10 Code cleanup: -getusedrange(); moved cropping result array to
##      "     calling function

function [ rawarr, xls, status ] = xls2jxla2oct (xls, wsh, cellrange=[], spsh_opts)

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
#	firstrow = 0;
#	lcol = 0;

	if (isempty (cellrange))
		# Get numeric sheet pointer (1-based)
		ii = 1;
		while (ii <= nr_of_sheets)
			if (strcmp (wsh, shnames{ii}) == 1)
				wsh = ii;
				ii = nr_of_sheets + 1;
			else
				++ii;
			endif
		endwhile
		# Get data rectangle row & column numbers (1-based)
		[firstrow, lastrow, lcol, rcol] = getusedrange (xls, wsh);
		nrows = lastrow - firstrow + 1;
		ncols = rcol - lcol + 1;
	else
		# Translate range to row & column numbers (1-based)
		[dummy, nrows, ncols, firstrow, lcol] = parse_sp_range (cellrange);
		# Check for too large requested range against actually present range
		lastrow = min (firstrow + nrows - 1, sh.getRows ());
		nrows = min (nrows, sh.getRows () - firstrow + 1);
		ncols = min (ncols, sh.getColumns () - lcol + 1);
		rcol = lcol + ncols - 1;
	endif

	# Read contents into rawarr
	rawarr = cell (nrows, ncols);			# create placeholder
	for jj = lcol : rcol
		for ii = firstrow:lastrow
			scell = sh.getCell (jj-1, ii-1);
			switch char (scell.getType ())
				case ctype {1, 1}   # Boolean
					rawarr (ii+1-firstrow, jj+1-lcol) = scell.getValue ();
				case ctype {2, 1}   # Boolean formula
					if (spsh_opts.formulas_as_text)
						tmp = scell.getFormula ();
						rawarr (ii+1-firstrow, jj+1-lcol) = ["=" tmp];
					else
						rawarr (ii+1-firstrow, jj+1-lcol) = scell.getValue ();
					endif
				case ctype {3, 1}   # Date
					rawarr (ii+1-firstrow, jj+1-lcol) = scell.getValue ();
				case ctype {4, 1}   # Date formula
					if (spsh_opts.formulas_as_text)
						tmp = scell.getFormula ();
						rawarr (ii+1-firstrow, jj+1-lcol) = ["=" tmp];
					else
						rawarr (ii+1-firstrow, jj+1-lcol) = scell.getValue ();
					endif
				case { ctype {5, 1}, ctype {6, 1}, ctype {7, 1} }
					# Empty, Error or Formula error. Nothing to do here
				case ctype {8, 1}   # Number
					rawarr (ii+1-firstrow, jj+1-lcol) = scell.getValue ();
				case ctype {9, 1}   # String
					rawarr (ii+1-firstrow, jj+1-lcol) = scell.getString ();
				case ctype {10, 1}  # Numerical formula
					if (spsh_opts.formulas_as_text)
						tmp = scell.getFormula ();
						rawarr (ii+1-firstrow, jj+1-lcol) = ["=" tmp];
					else
						rawarr (ii+1-firstrow, jj+1-lcol) = scell.getValue ();
					endif
				case ctype {11, 1}  # String formula
					if (spsh_opts.formulas_as_text)
						tmp = scell.getFormula ();
						rawarr (ii+1-firstrow, jj+1-lcol) = ["=" tmp];
					else
						rawarr (ii+1-firstrow, jj+1-lcol) = scell.getString ();
					endif
				otherwise
					# Do nothing
			endswitch
		endfor
	endfor

#	# Crop rawarr from empty outer rows & columns
#	emptr = cellfun('isempty', rawarr);
#	irowt = 1;
#	while (all (emptr(irowt, :))), irowt++; endwhile
#	irowb = nrows;
#	while (all (emptr(irowb, :))), irowb--; endwhile
#	icoll = 1;
#	while (all (emptr(:, icoll))), icoll++; endwhile
#	icolr = ncols;
#	while (all (emptr(:, icolr))), icolr--; endwhile
#	# Crop cell array
#	rawarr = rawarr(irowt:irowb, icoll:icolr);
	status = 1;

	xls.limits = [lcol, rcol; firstrow, lastrow];
	
endfunction
