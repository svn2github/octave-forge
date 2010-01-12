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
## Latest update: 2010-01-03 (OOXML support)

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

	else
		error (sprintf ("oct2xls: unknown Excel .xls interface - %s.", xls.xtype));

	endif

endfunction


#===================================================================================
## Copyright (C) 2007 by Michael Goffioul <michael.goffioul at swing.be>
##
## Adapted by P.R. Nienhuis <prnienhuis at users.sf.net> (2009)
## for more flexible writing into Excel worksheets through COM.
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
## @deftypefn {Function File} [@var{xlso}, @var{status}] = oct2com2xls (@var{obj}, @var{xlsi})
## @deftypefnx {Function File} [@var{xlso}, @var{status}] = oct2com2xls (@var{obj}, @var{xlsi}, @var{wsh})
## @deftypefnx {Function File} [@var{xlso}, @var{status}] = oct2com2xls (@var{obj}, @var{xlsi}, @var{wsh}, @var{top_left_cell})
## Save matrix @var{obj} into worksheet @var{wsh} in Excel file pointed
## to in struct @var{xlsi}. All elements of @var{obj} are converted into
## Excel cells, starting at cell @var{top_left_cell}. Return argument
## @var{xlso} is @var{xlsi} with updated fields.
##
## oct2com2xls should not be invoked directly but rather through oct2xls.
##
## Excel invocations may be left running invisibly in case of COM errors.
##
## Example:
##
## @example
##   xls = oct2com2xls (rand (10, 15), xls, 'Third_sheet', 'BF24');
## @end example
##
## @seealso oct2xls, xls2oct, xlsopen, xlsclose, xlswrite, xlsread, xls2com2oct
##
## @end deftypefn

## Author: Philip Nienhuis
## Rewritten: 2009-09-26
## Updates:
## 2009-12-11
## 2010-01-12 Fixed typearr sorting out (was only 1-dim & braces rather than parens))
##            Set cells corresponding to empty array cells empty (cf. Matlab)

function [ xls, status ] = oct2com2xls (obj, xls, wsh, top_left_cell='A1')

	# define some constants not yet in __COM__.cc
	xlWorksheet = -4167; # xlChart= 4;

	# scratch vars
	status = 0;

	# Preliminary sanity checks
	if (nargin < 2) error ("oct2com2xls needs a minimum of 2 arguments."); endif
	if (nargin == 2) wsh = 1; endif
	if (~iscell (obj)) error ("Cell array expected as input argument"); endif
	if (~strcmp (tolower (xls.filename(end-3:end)), '.xls'))
		error ("oct2com2xls can only write to Excel .xls files")
	endif
	if (isnumeric (wsh))
		if (wsh < 1) error ("Illegal worksheet number: %i\n", wsh); endif
	elseif (size (wsh, 2) > 31) 
		error ("Illegal worksheet name - too long")
	endif
	if (isempty (obj))
		warning ("Request to write empty matrix."); 
		rstatus = 1;
		return; 
	endif
	test1 = ~isfield (xls, "xtype");
	test1 = test1 || ~isfield (xls, "workbook");
	test1 = test1 || ~strcmp (char (xls.xtype), 'COM');
	test1 = test1 || isempty (xls.workbook);
	test1 = test1 || isempty (xls.app);
	if test1
		error ("Invalid file pointer struct");
	endif
	
	# Cleanup NaNs. Start with backing up strings, empty & boolean cells,
	# then set text cells to 0
	obj
	obj2 = cell (size (obj));
	txtptr = cellfun ('isclass', obj, 'char');
	if (any (any (txtptr))) obj2(txtptr) = obj(txtptr); obj(txtptr) = 0; endif
	eptr = cellfun ('isempty', obj); 
	if (any (any (eptr))) obj(eptr) = 0; endif
	lptr = cellfun ("islogical" , obj);
	if (any (any (lptr))) obj2(lptr) = obj(lptr); obj(lptr) = 0; endif

	ptr = cellfun ("isnan", obj);
	if (any (any (ptr))) obj{ptr} = []; endif

	# Restore text, empty cells & booleans
	if (any (any (txtptr))) obj(txtptr) = obj2(txtptr); endif
	if (any (any (lptr))) obj(lptr) = obj2(lptr); endif
	if (any (any (eptr))) obj(eptr) = {[]}; endif
	clear obj2 txtptr eptr lptr ptr;

	if (xls.changed < 2) 
		# Existing file. Some involved investigation is needed to preserve
		# existing data that shouldn't be touched.
		#
		# See if desired *sheet* name exists. 
		old_sh = 0;
		ws_cnt = xls.workbook.Sheets.count;
		if (isnumeric (wsh))
			if (wsh <= ws_cnt)
				# Here we check for sheet *position* in the sheet stack
				# rather than a name like "Sheet<Number>" 
				old_sh = wsh;
			else
				# wsh > nr of sheets; proposed new sheet name.
				# This sheet name can already exist to the left in the sheet stack!
				shnm = sprintf ("Sheet%d", wsh); shnm1 = shnm;
			endif
		endif
		if (~old_sh)
			# Check if the requested (or proposed) sheet already exists
			# COM objects are not OO (yet?), so we need a WHILE loop 
			ii = 1; jj = 1;
			while ((ii <= ws_cnt) && ~old_sh)
				# Get existing sheet names one by one
				sh_name = xls.workbook.Sheets(ii).name;
				if (~isnumeric (wsh) && strcmp (sh_name, wsh))
					# ...and check with requested sheet *name*...
					old_sh = ii;
				elseif (isnumeric (wsh) && strcmp (sh_name, shnm))
					# ... or proposed new sheet name (corresp. to requested sheet *number*)
					shnm = [shnm "_"];
					ii = 0;			# Also check if this new augmented sheet name exists...
					if (strmatch (shnm1, sh_name)), jj++; endif
					if (jj > 5) 	# ... but not unlimited times...
						error (sprintf (" > 5 sheets named [_]Sheet%d already present!", wsh));
					endif
				endif
				++ii;
			endwhile
		endif

		if (old_sh) 
			# Requested sheet exists. Check if it is a *work*sheet
			if ~(xls.workbook.Sheets(old_sh).Type == xlWorksheet)
				# Error as you can't write data to this
				error (sprintf ("Existing sheet '%s' is not type worksheet.", wsh));
			else
				# Simply point to the relevant sheet
				sh = xls.workbook.Worksheets (old_sh);
			endif
		else
			# Add a new worksheet. Earlier it was checked whether this is safe
			sh = xls.workbook.Worksheets.Add ();
			if (~isnumeric (wsh)) 
				sh.Name = wsh;
			else
				sh.Name = shnm;
				printf ("Writing to worksheet %s\n", shnm);
			endif
			# Prepare to move new sheet to right of the worksheet stack anyway
			ws_cnt = xls.workbook.Worksheets.count;			# New count needed
			# Find where Excel has left it. We have to, depends on Excel version :-(
			ii = 1;
			while ((ii < ws_cnt+1) && ~strcmp (sh.Name, xls.workbook.Worksheets(ii).Name) == 1)
				++ii;
			endwhile
			# Excel can't move it beyond the current last one, so we need a trick.
			# First move it to just before the last one....
			xls.workbook.Worksheets(ii).Move (before = xls.workbook.Worksheets(ws_cnt));
			# ....then move the last one before the new sheet.
			xls.workbook.Worksheets (ws_cnt).Move (before = xls.workbook.Worksheets(ws_cnt - 1));
		endif
		xls.changed = 1;

	else
		# The easy case: a new Excel file.
		# Workbook was created in xlsopen. Write to first worksheet:
		sh = xls.workbook.Worksheets (1);
		# Delete empty non-used sheets, last one first
		xls.app.Application.DisplayAlerts = 0;
		xls.workbook.Worksheets(3).Delete(); xls.workbook.Worksheets(2).Delete();
		xls.app.Application.DisplayAlerts = 1;

		# Rename the sheet
		if (isnumeric(wsh))
			sh.Name = sprintf("Sheet%i", wsh);
		else
			sh.Name = wsh;
		endif
		xls.changed = 2;
	endif
	
	# MG's original part.
	# Save object in Excel sheet, starting at cell top_left_cell
	if (~isempty(obj))
		r = sh.Range (top_left_cell);
		r = r.Resize (size (obj, 1), size (obj, 2));
		r.Value = obj;
		delete (r);
	endif

	# If we get here, all went OK
	status = 1;
	
endfunction


#====================================================================================

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
## Updates: 
## 2010-01-03 Bugfixes
## 2010-01-12 Added xls.changed = 1 statement to signal successful write

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
	typearr(lptr) = ctype(5);							# BOOLEAN, temp NUMERIC

	# Create formula evaluator (needed to be able to write boolean values!)
	frm_eval = xls.workbook.getCreationHelper ().createFormulaEvaluator ();

	for ii=1:nrows
		ll = ii + trow - 2;    		# Java POI's row count = 0-based
		row = sh.getRow (ll);
		if (isempty (row)) row = sh.createRow (ll); endif
		for jj=1:ncols
			kk = jj + lcol - 2;		# POI's column count is also 0-based
			if (typearr(ii, jj) == ctype(4))
				cell = row.createCell (kk, ctype(4));
			else
				cell = row.createCell (kk, typearr(ii,jj));
				cell.setCellValue (obj{ii, jj});
			endif
		endfor
	endfor

	xls.changed = 1;
	rstatus = 1;
  
endfunction


#====================================================================================
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
## @deftypefn {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jxla2xls ( @var{arr}, @var{xlsi})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jxla2xls (@var{arr}, @var{xlsi}, @var{wsh})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jxla2xls (@var{arr}, @var{xlsi}, @var{wsh}, @var{topleft})
##
## Add data in 1D/2D CELL array @var{arr} into a range with upper left
## cell equal to @var{topleft} in worksheet @var{wsh} in an Excel
## spreadsheet file pointed to in structure @var{range}.
## Return argument @var{xlso} equals supplied argument @var{xlsi} and is
## updated by oct2jxla2xls.
##
## oct2jxla2xls should not be invoked directly but rather through oct2xls.
##
## Example:
##
## @example
##   [xlso, status] = oct2jxla2oct ('arr', xlsi, 'Third_sheet', 'AA31');
## @end example
##
## @seealso oct2xls, xls2oct, xlsopen, xlsclose, xlsread, xlswrite, xls2jxla2oct
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-04
## Updates:
## 2009-12-11
## 2010-01-12 Fixed skipping empty array values (now Excel-conformant => cell cleared)
##            Added xls.changed = 1 statement to signal successful write

function [ xls, rstatus ] = oct2jxla2xls (obj, xls, wsh, topleftcell="A1")

	persistent ctype;
	if (isempty (ctype))
		ctype = [1, 2, 3, 4, 5];
		# Boolean, Number, String, NaN, Empty
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
	if (nargin < 2) error ("oct2java2xls needs a minimum of 2 arguments."); endif
	if (nargin == 2) wsh = 1; endif
	if (~strmatch(tolower(xls.filename(end-4:end)), '.xls'))	# FIXME for OOXML
		error ("oct2java2xls can only write to Excel .xls files")
	endif
	
	# Prepare workbook pointer if needed
	if (xls.changed < 2)
		# Create writable copy of workbook. If 2 a writable wb was made in xlsopen
		xlsout = java_new ('java.io.File', xls.filename);
		wb = java_invoke ('jxl.Workbook', 'createWorkbook', xlsout, xls.workbook);
		xls.changed = 1;			# For in case we come from reading the file
		xls.workbook = wb;
	else
		wb = xls.workbook;
	endif

	# Check if requested worksheet exists in the file & if so, get pointer
	nr_of_sheets = xls.workbook.getNumberOfSheets();	# 1 based !!
	if (isnumeric (wsh))
		if (wsh > nr_of_sheets)
			# Watch out as a sheet called Sheet%d can exist with a lower index...
			strng = sprintf ("Sheet%d", wsh);
			ii = 1;
			while (~isempty (wb.getSheet (strng)) && (ii < 5))
				strng = ['_' strng];
				++ii;
			endwhile
			if (ii >= 5) error (sprintf( " > 5 sheets named [_]Sheet%d already present!", wsh)); endif
			sh = wb.createSheet (strng, nr_of_sheets); ++nr_of_sheets;
		else
			sh = wb.getSheet (wsh - 1);			# POI sheet count 0-based
		endif
		shnames = char(wb.getSheetNames ());
		printf ("(Writing to worksheet %s)\n", 	shnames {nr_of_sheets, 1});
	else
		sh = wb.getSheet (wsh);
		if (isempty(sh))
			# Sheet not found, just create it
			sh = wb.createSheet (wsh, nr_of_sheets);
			++nr_of_sheets;
			xls.changed = 2;
		endif
	endif

	# Beware of strings variables interpreted as char arrays; change them to cell.
	if (ischar (obj)) obj = {obj}; endif
 
	[topleft, nrows, ncols, trow, lcol] = parse_sp_range (topleftcell);
	[nrows, ncols] = size (obj);

	# Prepare type array to speed up writing
	typearr = 5 * ones (nrows, ncols);				# type "EMPTY", provisionally
	obj2 = cell (size (obj));						# Temporary storage for strings

	txtptr = cellfun ('isclass', obj, 'char');		# type "STRING" replaced by "NUMERIC"
	obj2(txtptr) = obj(txtptr); obj(txtptr) = 3;	# Save strings in a safe place

	emptr = cellfun ("isempty", obj);
	obj(emptr) = 5;									# Set empty cells to NUMERIC

	lptr = cellfun ("islogical" , obj);				# Find logicals...
	obj2(lptr) = obj(lptr);							# .. and set them to BOOLEAN

	ptr = cellfun ("isnan", obj);					# Find NaNs & set to BLANK
	typearr(ptr) = 4; typearr(~ptr) = 2;			# All other cells are now numeric

	obj(txtptr) = obj2(txtptr);						# Copy strings back into place
	obj(lptr) = obj2(lptr);
	typearr(txtptr) = 3;							# ...and clean up 
	typearr(emptr) = 5;
	typearr(lptr) = 1;								# BOOLEAN

	# Write date to worksheet
	for ii=1:nrows
		ll = ii + trow - 2;    		# Java JExcelAPI's row count = 0-based
		for jj=1:ncols
			kk = jj + lcol - 2;		# JExcelAPI's column count is also 0-based
			switch typearr(ii, jj)
				case 1			# Boolean
					tmp = java_new ('jxl.write.Boolean', kk, ll, obj{ii, jj});
					sh.addCell (tmp);
				case 2			# Numerical
					tmp = java_new ('jxl.write.Number', kk, ll, obj{ii, jj});
					sh.addCell (tmp);
				case 3			# String
					tmp = java_new ('jxl.write.Label', kk, ll, obj{ii, jj});
					sh.addCell (tmp);
				case {4, 5}
					tmp = java_new ('jxl.write.Blank', kk, ll);
					sh.addCell (tmp);
				otherwise
					# Just skip
			endswitch
		endfor
	endfor
	
	xls.changed = 1;
	rstatus = 1;
  
endfunction

