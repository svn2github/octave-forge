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
## @deftypefn {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jpoi2xls ( @var{arr}, @var{xlsi})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jpoi2xls (@var{arr}, @var{xlsi}, @var{wsh})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jpoi2xls (@var{arr}, @var{xlsi}, @var{wsh}, @var{topleft})
##
## Add data in 1D/2D CELL array @var{arr} into a range with upper left
## cell equal to @var{topleft} in worksheet @var{wsh} in an Excel
## spreadsheet file pointed to in structure @var{range}.
## Return argument @var{xlso} equals supplied argument @var{xlsi} and is
## updated by oct2java2xls.
##
## oct2jpoi2xls should not be invoked directly but rather through oct2xls.
##
## Example:
##
## @example
##   [xlso, status] = xls2jpoi2oct ('arr', xlsi, 'Third_sheet', 'AA31');
## @end example
##
## @seealso oct2xls, xls2oct, xlsopen, xlsclose, xlsread, xlswrite
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-11-26
## Last updated 2009-12-11

function [ xls, rstatus ] = oct2jpoi2xls (obj, xls, wsh, topleftcell="A1")

	persistent ctype;
	if (isempty (ctype))
		# Get cell types. Beware as they start at 0 not 1
		ctype(1) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_NUMERIC');
		ctype(2) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_STRING');
		ctype(3) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_FORMULA');
		ctype(4) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_BLANK');
		ctype(5) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_BOOLEAN');
		ctype(6) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_ERROR');
	endif

	# scratch vars
	rstatus = 0; changed = 1;

	# Preliminary sanity checks
	if (isempty (obj))
		warning ("Request to write empty matrix."); 
		rstatus = 1;
		return; 
	elseif (~iscell(obj))
 		error ("First argument is not a cell array");
	endif
	if (nargin < 2) error ("oct2jpoi2xls needs a minimum of 2 arguments."); endif
	if (nargin == 2) wsh = 1; endif
	if (~strmatch(tolower(xls.filename(end-4:end)), '.xls'))
		error ("oct2jpoi2xls can only write to Excel .xls or .xlsx files")
	endif
	# Check if xls struct pointer seems valid
	test1 = ~isfield (xls, "xtype");
	test1 = test1 || ~isfield (xls, "workbook");
	test1 = test1 || ~strcmp (char (xls.xtype), 'POI');
	test1 = test1 || isempty (xls.workbook);
	test1 = test1 || isempty (xls.app);
	if test1 error ("Invalid xls file struct"); endif

	# Check if requested worksheet exists in the file & if so, get pointer
	nr_of_sheets = xls.workbook.getNumberOfSheets();
	if (isnumeric (wsh))
		if (wsh > nr_of_sheets)
			# Watch out as a sheet called Sheet%d can exist with a lower index...
			strng = sprintf ("Sheet%d", wsh);
			ii = 1;
			while (~isempty (xls.workbook.getSheet (strng)) && (ii < 5))
				strng = ['_' strng];
				++ii;
			endwhile
			if (ii >= 5) error (sprintf( " > 5 sheets named [_]Sheet%d already present!", wsh)); endif
			sh = xls.workbook.createSheet (strng);
		else
			sh = xls.workbook.getSheetAt (wsh - 1);			# POI sheet count 0-based
		endif
		printf ("(Writing to worksheet %s)\n", 	sh.getSheetName());	
	else
		sh = xls.workbook.getSheet (wsh);
		if (isempty(sh))
			# Sheet not found, just create it
			sh = xls.workbook.createSheet (wsh);
			xls.changed = 2;
		endif
	endif

	# Beware of strings variables interpreted as char arrays; change them to cell.
	if (ischar (obj)) obj = {obj}; endif
 
	[topleft, nrows, ncols, trow, lcol] = parse_sp_range (topleftcell);
	[nrows, ncols] = size (obj);

	# Prepare type array
	typearr = ctype(4) * ones (nrows, ncols);			# type "BLANK", provisionally
	obj2 = cell (size (obj));							# Temporary storage for strings

	txtptr = cellfun ('isclass', obj, 'char');			# type "STRING" replaced by "NUMERIC"
	obj2(txtptr) = obj(txtptr); obj(txtptr) = ctype(1);	# Save strings in a safe place

	emptr = cellfun ("isempty", obj);
	obj(emptr) = ctype(1);								# Set empty cells to NUMERIC

	lptr = cellfun ("islogical" , obj);					# Find logicals...
	obj2(lptr) = obj(lptr);								# .. and set them to BOOLEAN

	ptr = cellfun ("isnan", obj);						# Find NaNs & set to BLANK
	typearr(ptr) = ctype(4); typearr(~ptr) = ctype(1);	# All other cells are now numeric

	obj(txtptr) = obj2(txtptr);							# Copy strings back into place
	obj(lptr) = obj2(lptr);
	typearr(txtptr) = ctype(2);							# ...and clean up 
	typearr(emptr) = ctype(4);
	typearr(lptr) = ctype(5);							# BOOLEAN

	# Create formula evaluator (needed to be able to write boolean values!)
	frm_eval = xls.workbook.getCreationHelper().createFormulaEvaluator();

	for ii=1:nrows
		ll = ii + trow - 2;    		# Java POI's row count = 0-based
		row = sh.getRow (ll);
		if (isempty (row)) row = sh.createRow (ll); endif
		for jj=1:ncols
			kk = jj + lcol - 2;		# POI's column count is also 0-based
			cell = row.createCell (kk, typearr(ii,jj));
			if (typearr(ii, jj) == ctype(5))
				cell = row.createCell (kk, ctype(3));
				# Provisionally we make do with formulas evaluated immediately 8-Z
				if obj{ii, jj} bool = '(1=1)'; else bool = '(1=0)'; endif
				cell.setCellFormula (bool); frm_eval.evaluateInCell (cell);
			elseif ~(typearr(ii, jj) == 3)
				# Just put text or number in cell
				cell.setCellValue (obj{ii, jj});
			endif
		endfor
	endfor
	
	rstatus = 1;
  
endfunction
