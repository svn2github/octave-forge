## Copyright (C) 2009,2010,2011,2012 Philip Nienhuis <prnienhuis at users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [ @var{xls}, @var{rstatus} ] = oct2xls (@var{arr}, @var{xls})
## @deftypefnx {Function File} [ @var{xls}, @var{rstatus} ] = oct2xls (@var{arr}, @var{xls}, @var{wsh})
## @deftypefnx {Function File} [ @var{xls}, @var{rstatus} ] = oct2xls (@var{arr}, @var{xls}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{xls}, @var{rstatus} ] = oct2xls (@var{arr}, @var{xls}, @var{wsh}, @var{range}, @var{options})
##
## Add data in 1D/2D CELL array @var{arr} into a cell range specified in
## @var{range} in worksheet @var{wsh} in an Excel spreadsheet file
## pointed to in structure @var{xls}.
## Return argument @var{xls} equals supplied argument @var{xls} and is
## updated by oct2xls.
##
## A subsequent call to xlsclose is needed to write the updated spreadsheet
## to disk (and -if needed- close the Excel or Java invocation).
##
## @var{arr} can be any 1D or 2D array containing numerical or character
## data (cellstr) except complex. Mixed numeric/text arrays can only be
## cell arrays.
##
## @var{xls} must be a valid pointer struct created earlier by xlsopen.
##
## @var{wsh} can be a number or string (max. 31 chars).
## In case of a yet non-existing Excel file, the first worksheet will be
## used & named according to @var{wsh} - extra empty worksheets that Excel
## creates by default are deleted.
## In case of existing files, some checks are made for existing worksheet
## names or numbers, or whether @var{wsh} refers to an existing sheet with
## a type other than worksheet (e.g., chart).
## When new worksheets are to be added to the Excel file, they are
## inserted to the right of all existing worksheets. The pointer to the
## "active" sheet (shown when Excel opens the file) remains untouched.
##
## If @var{range} is omitted or just the top left cell of the range is
## specified, the actual range to be used is determined by the size of
## @var{arr}. If nothing is specified for @var{range} the top left cell
## is assumed to be 'A1'.
##
## Data are added to the worksheet, ignoring other data already present;
## existing data in the range to be used will be overwritten.
##
## If @var{range} contains merged cells, only the elements of @var{arr}
## corresponding to the top or left Excel cells of those merged cells
## will be written, other array cells corresponding to that cell will be
## ignored.
##
## Optional argument @var{options}, a structure, can be used to specify
## various write modes.
## Currently the only option field is "formulas_as_text", which -if set
## to 1 or TRUE- specifies that formula strings (i.e., text strings
## starting with "=" and ending in a ")" ) should be entered as litteral
## text strings rather than as spreadsheet formulas (the latter is the
## default).
##
## Beware that -if invoked- Excel invocations may be left running silently
## in case of COM errors. Invoke xlsclose with proper pointer struct to
## close them.
## When using Java, note that large data array sizes elements may exhaust
## the Java shared memory space for the default java memory settings.
## For larger arrays, appropriate memory settings are needed in the file
## java.opts; then the maximum array size for the Java-based spreadsheet
## options may be in the order of 10^6 elements. In caso of UNO this
## limit is not applicable and spreadsheets may be much larger.
##
## Examples:
##
## @example
##   [xlso, status] = xls2oct ('arr', xlsi, 'Third_sheet', 'AA31:AB278');
## @end example
##
## @seealso {xls2oct, xlsopen, xlsclose, xlsread, xlswrite, xlsfinfo}
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-01
## Updates: 
## 2010-01-03 (OOXML support)
## 2010-03-14 Updated help text section on java memory usage
## 2010-07-27 Added formula writing support (based on patch by Benjamin Lindner)
## 2010-08-01 Added check on input array size vs. spreadsheet capacity
##     ''     Changed argument topleft into range (now compatible with ML); the
##     ''     old argument version (just topleft cell) is still recognized, though
## 2010-08014 Added char array conversion to 1x1 cell for character input arrays
## 2010-08-16 Added check on presence of output argument. Made wsh = 1 default
## 2010-08-17 Corrected texinfo ("topleft" => "range")
## 2010-08-25 Improved help text (section on java memory usage)
## 2010-11-12 Moved ptr struct check into main func. More input validity checks
## 2010-11-13 Added check for 2-D input array
## 2010-12-01 Better check on file pointer struct (ischar (xls.xtype))
## 2011-03-29 OpenXLS support added. Works but saving to file (xlsclose) doesn't work yet 
##      ''    Bug fixes (stray variable c_arr, and wrong test for valid xls struct)
## 2011-05-18 Experimental UNO support
## 2011-09-08 Bug fix in range arg check; code cleanup
## 2011-11-18 Fixed another bug in test for range parameter being character string
## 2012-01-26 Fixed "seealso" help string
## 2012-02-20 Fixed range parameter to be default empty string rather than empty numeral
## 2012-02-27 More range param fixes
## 2012-03-07 Updated texinfo help text
## 2012-05-22 Cast all numeric data in input array to double

## Last script file update (incl. subfunctions): 2012-05-21

function [ xls, rstatus ] = oct2xls (obj, xls, wsh=1, crange='', spsh_opts=[])

	if (nargin < 2) error ("oct2xls needs a minimum of 2 arguments."); endif
  
	# Validate input array, make sure it is a cell array
	if (isempty (obj))
		warning ("Request to write empty matrix - ignored."); 
		rstatus = 1;
		return;
	elseif (isnumeric (obj))
		obj = num2cell (obj);
	elseif (ischar (obj))
		obj = {obj};
		printf ("(oct2xls: input character array converted to 1x1 cell)\n");
	elseif (~iscell (obj))
		error ("oct2xls: input array neither cell nor numeric array");
	endif
	if (ndims (obj) > 2), error ("Only 2-dimensional arrays can be written to spreadsheet"); endif
  # Cast all numerical values to double as spreadsheets only have double/boolean/text type
  idx = cellfun (@isnumeric, obj, "UniformOutput", true);
  obj(idx) = cellfun (@double, obj(idx), "UniformOutput", false);

	# Check xls file pointer struct
	test1 = ~isfield (xls, "xtype");
	test1 = test1 || ~isfield (xls, "workbook");
	test1 = test1 || isempty (xls.workbook);
	test1 = test1 || isempty (xls.app);
	test1 = test1 || ~ischar (xls.xtype);
	if (test1)
		error ("Invalid xls file pointer struct");
	endif

	# Check worksheet ptr
	if (~(ischar (wsh) || isnumeric (wsh))), error ("Integer (index) or text (wsh name) expected for arg # 3"); endif

	# Check range
	if (~isempty (crange) && ~ischar (crange))
    error ("Character string (range) expected for arg # 4");
  elseif (isempty (crange))
    crange = '';
  endif

	# Various options 
	if (isempty (spsh_opts))
		spsh_opts.formulas_as_text = 0;
		# other options to be implemented here
	elseif (isstruct (spsh_opts))
		if (~isfield (spsh_opts, 'formulas_as_text')), spsh_opts.formulas_as_text = 0; endif
		# other options to be implemented here
	else
		error ("Structure expected for arg # 5");
	endif
	
	if (nargout < 1) printf ("Warning: no output spreadsheet file pointer specified.\n"); endif
	
	# Select interface to be used
	if (strcmpi (xls.xtype, 'COM'))
		# Call oct2com2xls to do the work
		[xls, rstatus] = oct2com2xls (obj, xls, wsh, crange, spsh_opts);
	elseif (strcmpi (xls.xtype, 'POI'))
		# Invoke Java and Apache POI
		[xls, rstatus] = oct2jpoi2xls (obj, xls, wsh, crange, spsh_opts);
	elseif (strcmpi (xls.xtype, 'JXL'))
		# Invoke Java and JExcelAPI
		[xls, rstatus] = oct2jxla2xls (obj, xls, wsh, crange, spsh_opts);
	elseif (strcmpi (xls.xtype, 'OXS'))
		# Invoke Java and OpenXLS     ##### Not complete, saving file doesn't work yet!
		printf ('Sorry, writing with OpenXLS not reliable => not supported yet\n');
#		[xls, rstatus] = oct2oxs2xls (obj, xls, wsh, crange, spsh_opts);
	elseif (strcmpi (xls.xtype, 'UNO'))
		# Invoke Java and UNO bridge (OpenOffice.org)
		[xls, rstatus] = oct2uno2xls (obj, xls, wsh, crange, spsh_opts);
#	elseif (strcmpi (xls.xtype, '<whatever>'))
#		<Other Excel interfaces>
	else
		error (sprintf ("oct2xls: unknown Excel .xls interface - %s.", xls.xtype));
	endif

endfunction


#===================================================================================
## Copyright (C) 2009,2010,2011,2012 by Philip Nienhuis <prnienhuis@users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

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
## @seealso {oct2xls, xls2oct, xlsopen, xlsclose, xlswrite, xlsread, xls2com2oct}
##
## @end deftypefn

## Author: Philip Nienhuis  (originally based on mat2xls by Michael Goffioul)
## Rewritten: 2009-09-26
## Updates:
## 2009-12-11
## 2010-01-12 Fixed typearr sorting out (was only 1-dim & braces rather than parens))
##            Set cells corresponding to empty array cells empty (cf. Matlab)
## 2010-01-13 Removed an extraneous statement used for debugging 
##            I plan look at it when octave v.3.4 is about to arrive.
## 2010-08-01 Added checks for input array size vs check on capacity
##     ''     Changed topleft arg into range arg (just topleft still recognized)
##     ''     Some code cleanup
##     ''     Added option for formula input as text string
## 2010-08-01 Added range vs. array size vs. capacity checks
## 2010-08-03 Moved range checks and type array parsing to separate functions
## 2010-10-20 Bug fix removing new empty sheets in new workbook that haven't been 
##            created in the first place due to Excel setting (thanks Ian Journeaux)
##     ''     Changed range use in COM transfer call
## 2010-10-21 Improved file change tracking (var xls.changed)
## 2010-10-24 Fixed bug introduced in above fix: for loops have no stride param,
##     ''     replaced by while loop
##     ''     Added check for "live" ActiveX server
## 2010-11-12 Moved ptr struct check into main func
## 2012-01-26 Fixed "seealso" help string
## 2012-02-27 Copyright strings updated

function [ xls, status ] = oct2com2xls (obj, xls, wsh, crange, spsh_opts)

	# Preliminary sanity checks
	if (~strmatch (lower (xls.filename(end-4:end)), '.xls'))
		error ("oct2com2xls can only write to Excel .xls or .xlsx files")
	endif
	if (isnumeric (wsh))
		if (wsh < 1) error ("Illegal worksheet number: %i\n", wsh); endif
	elseif (size (wsh, 2) > 31) 
		error ("Illegal worksheet name - too long")
	endif
	# Check to see if ActiveX is still alive
	try
		wb_cnt = xls.workbook.Worksheets.count;
	catch
		error ("ActiveX invocation in file ptr struct seems non-functional");
	end_try_catch

	# define some constants not yet in __COM__.cc
	xlWorksheet = -4167; # xlChart= 4;
	# scratch vars
	status = 0;

	# Parse date ranges  
	[nr, nc] = size (obj);
	[topleft, nrows, ncols, trow, lcol] = spsh_chkrange (crange, nr, nc, xls.xtype, xls.filename);
	lowerright = calccelladdress (trow + nrows - 1, lcol + ncols - 1);
	crange = [topleft ':' lowerright];
	if (nrows < nr || ncols < nc)
		warning ("Array truncated to fit in range");
		obj = obj(1:nrows, 1:ncols);
	endif
	
	# Cleanup NaNs. Find where they are and mark as empty
	ctype = [0 1 2 3 4];							# Numeric Boolean Text Formula Empty
	typearr = spsh_prstype (obj, nrows, ncols, ctype, spsh_opts);
	# Make cells now indicated to be empty, empty
	fptr = ~(4 * (ones (size (typearr))) .- typearr);
	obj(fptr) = cellfun (@(x) [], obj(fptr), "Uniformoutput",  false);

	if (spsh_opts.formulas_as_text)
		# find formulas (designated by a string starting with "=" and ending in ")")
		fptr = cellfun (@(x) ischar (x) && strncmp (x, "=", 1) && strncmp (x(end:end), ")", 1), obj);
		# ... and add leading "'" character
		obj(fptr) = cellfun (@(x) ["'" x], obj(fptr), "Uniformoutput", false); 
	endif
	clear fptr;

	if (xls.changed < 3) 
		# Existing file OR a new file with data added in a previous oct2xls call.
		# Some involved investigation is needed to preserve
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
				# Error as you can't write data to Chart sheet
				error (sprintf ("Existing sheet '%s' is not type worksheet.", wsh));
			else
				# Simply point to the relevant sheet
				sh = xls.workbook.Worksheets (old_sh);
			endif
		else
			# Add a new worksheet. Earlier it was checked whether this is safe
			try
				sh = xls.workbook.Worksheets.Add ();
			catch
				error (sprintf ("Cannot add new worksheet to file %s\n", xls.filename));
			end_try_catch
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

	else
		# The easy case: a new Excel file. Workbook was created in xlsopen. 

		# Delete empty non-used sheets, last one first
		xls.app.Application.DisplayAlerts = 0;
		ii = xls.workbook.Sheets.count;
		while (ii > 1)
			xls.workbook.Worksheets(ii).Delete();
			--ii;
		endwhile
		xls.app.Application.DisplayAlerts = 1;

		# Write to first worksheet:
		sh = xls.workbook.Worksheets (1);
		# Rename the sheet
		if (isnumeric (wsh))
			sh.Name = sprintf ("Sheet%i", wsh);
		else
			sh.Name = wsh;
		endif
		xls.changed = 2;			# 3 => 2
	endif

	# MG's original part.
	# Save object in Excel sheet, starting at cell top_left_cell
	if (~isempty(obj))
		r = sh.Range (crange);
		try
			r.Value = obj;
		catch
			error (sprintf ("Cannot add data to worksheet %s in file %s\n", sh.Name, xls.filename));
		end_try_catch
		delete (r);
	endif

	# If we get here, all went OK
	status = 1;
	xls.changed = max (xls.changed, 1);			# If it was 2, preserve it.
	
endfunction


#====================================================================================

## Copyright (C) 2009,2010,2011,2012 Philip Nienhuis <prnienhuis at users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jpoi2xls ( @var{arr}, @var{xlsi})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jpoi2xls (@var{arr}, @var{xlsi}, @var{wsh})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jpoi2xls (@var{arr}, @var{xlsi}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jpoi2xls (@var{arr}, @var{xlsi}, @var{wsh}, @var{range}, @var{options})
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
## @seealso {oct2xls, xls2oct, xlsopen, xlsclose, xlsread, xlswrite}
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-11-26
## Updates: 
## 2010-01-03 Bugfixes
## 2010-01-12 Added xls.changed = 1 statement to signal successful write
## 2010-03-08 Dumped formula evaluator for booleans. Not being able to 
##            write booleans was due to a __java__.oct deficiency (see
##            http://sourceforge.net/mailarchive/forum.php?thread_name=4B59A333.5060302%40net.in.tum.de&forum_name=octave-dev )
## 2010-07-27 Added formula writing support (based on patch by Benjamin Lindner)
## 2010-08-01 Improved try-catch for formulas to enter wrong formulas as text strings
## 2010-08-01 Added range vs. array size vs. capacity checks
## 2010-08-03 Moved range checks and type array parsingto separate functions
## 2010-10-21 Improved logic for tracking file changes
## 2010-10-27 File change tracking again refined, internal var 'changed' dropped
## 2010-11-12 Moved ptr struct check into main func
## 2011-11-19 Try-catch added to allow for changed method name for nr of worksheets
## 2012-01-26 Fixed "seealso" help string
## 2012-02-27 Copyright strings updated
## 2012-05-21 "Double" cast added when writing numeric values
## 2012-05-21 "Double" cast moved into main func oct2xls

function [ xls, rstatus ] = oct2jpoi2xls (obj, xls, wsh, crange, spsh_opts)

	# Preliminary sanity checks
	if (~strmatch (tolower (xls.filename(end-4:end)), '.xls'))
		error ("oct2jpoi2xls can only write to Excel .xls or .xlsx files")
	endif

	persistent ctype;
	if (isempty (ctype))
		# Get cell types. Beware as they start at 0 not 1
		ctype(1) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_NUMERIC');	# 0
		ctype(2) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_BOOLEAN');	# 4
		ctype(3) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_STRING');	# 1
		ctype(4) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_FORMULA');	# 2
		ctype(5) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_BLANK');	# 3
	endif
	# scratch vars
	rstatus = 0; f_errs = 0;

	# Check if requested worksheet exists in the file & if so, get pointer
	try
    nr_of_sheets = xls.workbook.getNumWorkSheets ();
  catch
    nr_of_sheets = xls.workbook.getNumberOfSheets ();
  end_try_catch
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
			xls.changed = min (xls.changed, 2);				# Keep 2 for new files
		else
			sh = xls.workbook.getSheetAt (wsh - 1);			# POI sheet count 0-based
		endif
		printf ("(Writing to worksheet %s)\n", 	sh.getSheetName ());	
	else
		sh = xls.workbook.getSheet (wsh);
		if (isempty (sh))
			# Sheet not found, just create it
			sh = xls.workbook.createSheet (wsh);
			xls.changed = min (xls.changed, 2);				# Keep 2 or 3 f. new files
		endif
	endif

	# Parse date ranges  
	[nr, nc] = size (obj);
	[topleft, nrows, ncols, trow, lcol] = spsh_chkrange (crange, nr, nc, xls.xtype, xls.filename);
	if (nrows < nr || ncols < nc)
		warning ("Array truncated to fit in range");
		obj = obj(1:nrows, 1:ncols);
	endif

	# Prepare type array
	typearr = spsh_prstype (obj, nrows, ncols, ctype, spsh_opts);
	if ~(spsh_opts.formulas_as_text)
		# Remove leading '=' from formula strings
		# FIXME should be easier using typearr<4> info
		fptr = ~(2 * (ones (size (typearr))) .- typearr);
		obj(fptr) = cellfun (@(x) x(2:end), obj(fptr), "Uniformoutput", false); 
	endif

	# Create formula evaluator
	frm_eval = xls.workbook.getCreationHelper ().createFormulaEvaluator ();

	for ii=1:nrows
		ll = ii + trow - 2;    		# Java POI's row count = 0-based
		row = sh.getRow (ll);
		if (isempty (row)) row = sh.createRow (ll); endif
		for jj=1:ncols
			kk = jj + lcol - 2;		# POI's column count is also 0-based
			if (typearr(ii, jj) == ctype(5))			# Empty cells
				cell = row.createCell (kk, ctype(5));
			elseif (typearr(ii, jj) == ctype(4))		# Formulas
				# Try-catch needed as there's no guarantee for formula correctness
				try
					cell = row.createCell (kk, ctype(4));
					cell.setCellFormula (obj{ii,jj});
				catch									
					++f_errs;
					cell.setCellType (ctype (3));		# Enter formula as text
					cell.setCellValue (obj{ii, jj});
				end_try_catch
			else
				cell = row.createCell (kk, typearr(ii,jj));
        if (isnumeric (obj{ii, jj}))
          cell.setCellValue (obj{ii, jj});
        else
          cell.setCellValue (obj{ii, jj});
        endif
			endif
		endfor
	endfor
	
	if (f_errs) 
		printf ("%d formula errors encountered - please check input array\n", f_errs); 
	endif
	xls.changed = max (xls.changed, 1);	   # Preserve a "2"
	rstatus = 1;
  
endfunction


#====================================================================================
## Copyright (C) 2009,2010,2011,2012 Philip Nienhuis <prnienhuis at users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jxla2xls ( @var{arr}, @var{xlsi})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jxla2xls (@var{arr}, @var{xlsi}, @var{wsh})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jxla2xls (@var{arr}, @var{xlsi}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2jxla2xls (@var{arr}, @var{xlsi}, @var{wsh}, @var{range}, @var{options})
##
## Add data in 1D/2D CELL array @var{arr} into spreadsheet cell range @var{range}
## in worksheet @var{wsh} in an Excel spreadsheet file pointed to in structure
## @var{range}.
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
## @seealso {oct2xls, xls2oct, xlsopen, xlsclose, xlsread, xlswrite, xls2jxla2oct}
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-04
## Updates:
## 2009-12-11
## 2010-01-12 Fixed skipping empty array values (now Excel-conformant => cell cleared)
##            Added xls.changed = 1 statement to signal successful write
## 2010-07-27 Added formula writing support (based on POI patch by Benjamin Lindner)
##            Added check for valid file pointer struct
## 2010-08-01 Improved try-catch for formulas to enter wrong formulas as text strings
## 2010-08-01 Added range vs. array size vs. capacity checks
##     ''     Code cleanup
##     ''     Changed topleft arg into range arg (topleft version still recognized)
## 2010-08-03 Moved range checks and cell type parsing to separate routines
## 2010-08-11 Moved addcell() into try-catch as it is addCell which throws fatal errors
## 2010-10-20 Improved logic for tracking file changes (xls.changed 2 or 3); dropped
##     ''      internal variable 'changed'
## 2010-10-27 File change tracking again refined
## 2010-11-12 Moved ptr struct check into main func
## 2012-01-26 Fixed "seealso" help string
## 2012-02-27 Copyright strings updated
## 2012-05-21 "Double" cast added when writing numeric values
## 2012-05-21 "Double" cast moved into main func oct2xls

function [ xls, rstatus ] = oct2jxla2xls (obj, xls, wsh, crange, spsh_opts)

	# Preliminary sanity checks
	if (~strmatch (tolower (xls.filename(end-4:end-1)), '.xls'))	# No OOXML in JXL
		error ("JExcelAPI can only write to Excel .xls files")
	endif

	persistent ctype;
	if (isempty (ctype))
		ctype = [1, 2, 3, 4, 5];
		# Number, Boolean, String, Formula, Empty
	endif
	# scratch vars
	rstatus = 0; f_errs = 0;
	
	# Prepare workbook pointer if needed
	if (xls.changed == 0)			# Only for 1st call of octxls after xlsopen
		# Create writable copy of workbook. If >2 a writable wb was made in xlsopen
		xlsout = java_new ('java.io.File', xls.filename);
		wb = java_invoke ('jxl.Workbook', 'createWorkbook', xlsout, xls.workbook);
		# Catch JExcelAPI bug/"feature": when switching to write mode, the file on disk
		# is affected and the memory file MUST be written to disk to save earlier data
		xls.changed = 1;
		xls.workbook = wb;
	else
		wb = xls.workbook;
	endif
	# Check if requested worksheet exists in the file & if so, get pointer
	nr_of_sheets = xls.workbook.getNumberOfSheets ();	# 1 based !!
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
			xls.changed = min (xls.changed, 2);		# Keep a 2 in case of new file
		else
			sh = wb.getSheet (wsh - 1);				# JXL sheet count 0-based
		endif
		shnames = char (wb.getSheetNames ());
		printf ("(Writing to worksheet %s)\n", 	shnames {nr_of_sheets, 1});
	else
		sh = wb.getSheet (wsh);
		if (isempty(sh))
			# Sheet not found, just create it
			sh = wb.createSheet (wsh, nr_of_sheets);
			++nr_of_sheets;
			xls.changed = min (xls.changed, 2);		# Keep a 2 for new file
		endif
	endif

	# Parse date ranges  
	[nr, nc] = size (obj);
	[topleft, nrows, ncols, trow, lcol] = spsh_chkrange (crange, nr, nc, xls.xtype, xls.filename);
	if (nrows < nr || ncols < nc)
		warning ("Array truncated to fit in range");
		obj = obj(1:nrows, 1:ncols);
	endif

	# Prepare type array
	typearr = spsh_prstype (obj, nrows, ncols, ctype, spsh_opts);
	if ~(spsh_opts.formulas_as_text)
		# Remove leading '=' from formula strings
		fptr = ~(4 * (ones (size (typearr))) .- typearr);
		obj(fptr) = cellfun (@(x) x(2:end), obj(fptr), "Uniformoutput", false); 
	endif
	clear fptr

	# Write date to worksheet
	for ii=1:nrows
		ll = ii + trow - 2;    		# Java JExcelAPI's row count = 0-based
		for jj=1:ncols
			kk = jj + lcol - 2;		# JExcelAPI's column count is also 0-based
			switch typearr(ii, jj)
				case 1			# Numerical
					tmp = java_new ('jxl.write.Number', kk, ll, obj{ii, jj});
					sh.addCell (tmp);
				case 2			# Boolean
					tmp = java_new ('jxl.write.Boolean', kk, ll, obj{ii, jj});
					sh.addCell (tmp);
				case 3			# String
					tmp = java_new ('jxl.write.Label', kk, ll, obj{ii, jj});
					sh.addCell (tmp);
				case 4			# Formula
					# First make sure formula functions are all uppercase
					obj{ii, jj} = toupper (obj{ii, jj});
					# There's no guarantee for formula correctness, so....
					try		# Actually JExcelAPI flags formula errors as mere warnings :-(
						tmp = java_new ('jxl.write.Formula', kk, ll, obj{ii, jj});
						# ... while errors are actually detected in addCell(), so
						#     that should be within the try-catch
						sh.addCell (tmp);
					catch
						++f_errs;
						# Formula error. Enter formula as text string instead
						tmp = java_new ('jxl.write.Label', kk, ll, obj{ii, jj});
						sh.addCell (tmp);
					end_try_catch
				case 5		# Empty or NaN
					tmp = java_new ('jxl.write.Blank', kk, ll);
					sh.addCell (tmp);
				otherwise
					# Just skip
			endswitch
		endfor
	endfor
	
	if (f_errs) 
		printf ("%d formula errors encountered - please check input array\n", f_errs); 
	endif
	xls.changed = max (xls.changed, 1);		# Preserve 2 for new files
	rstatus = 1;
  
endfunction


## Copyright (C) 2011 Philip Nienhuis <prnienhuis@users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [ @var{xlso}, @var{rstatus} ] = oct2oxs2xls ( @var{arr}, @var{xlsi})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2oxs2xls (@var{arr}, @var{xlsi}, @var{wsh})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2oxs2xls (@var{arr}, @var{xlsi}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{xlso}, @var{rstatus} ] = oct2oxs2xls (@var{arr}, @var{xlsi}, @var{wsh}, @var{range}, @var{options})
##
## Add data in 1D/2D CELL array @var{arr} into spreadsheet cell range @var{range}
## in worksheet @var{wsh} in an Excel spreadsheet file pointed to in structure
## @var{range}.
## Return argument @var{xlso} equals supplied argument @var{xlsi} and is
## updated by oct2oxs2xls.
##
## oct2oxs2xls should not be invoked directly but rather through oct2xls.
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2011-03-29
## Updates:
##

function [ xls, rstatus ] = oct2oxs2xls (obj, xls, wsh, crange, spsh_opts)

	# Preliminary sanity checks
	if (~strmatch (tolower (xls.filename(end-4:end-1)), '.xls'))	# No OOXML in OXS
		error ("OXS can only write to Excel .xls files")
	endif
	
	changed = 0;

	persistent ctype;
	if (isempty (ctype))
		ctype = [1, 2, 3, 4, 5];
		# Number, Boolean, String, Formula, Empty
	endif
	# scratch vars
	rstatus = 0; f_errs = 0;
	
	# Prepare workbook pointer if needed
	wb = xls.workbook;

	# Check if requested worksheet exists in the file & if so, get pointer
	nr_of_sheets = wb.getNumWorkSheets ();			# 1 based !!
	if (isnumeric (wsh))
		if (wsh > nr_of_sheets)
			# Watch out as a sheet called Sheet%d can exist with a lower index...
			strng = sprintf ("Sheet%d", wsh);
			ii = 1;
			try
				# While loop should be inside try-catch
				while (ii < 5)
					sh = wb.getWorkSheet (strng)
					strng = ['_' strng];
					++ii;
				endwhile
			catch
				# No worksheet named <strng> found => we can proceed
			end_try_catch
			if (ii >= 5) error (sprintf( " > 5 sheets named [_]Sheet%d already present!", wsh)); endif
			sh = wb.createWorkSheet (strng); ++nr_of_sheets;
			xls.changed = min (xls.changed, 2);		# Keep a 2 in case of new file
		else
			sh = wb.getWorkSheet (wsh - 1);			# OXS sheet count 0-based
		endif
		printf ("(Writing to worksheet %s)\n", sh.getSheetName ());
	else
		try
			sh = wb.getWorkSheet (wsh);
		catch
			# Sheet not found, just create it
			sh = wb.createWorkSheet (wsh); ++nr_of_sheets;
			xls.changed = min (xls.changed, 2);		# Keep a 2 for new file
		end_try_catch
	endif

	# Parse date ranges  
	[nr, nc] = size (obj);
	[topleft, nrows, ncols, trow, lcol] = spsh_chkrange (crange, nr, nc, xls.xtype, xls.filename);
	if (nrows < nr || ncols < nc)
		warning ("Array truncated to fit in range");
		obj = obj(1:nrows, 1:ncols);
	endif

	# Prepare type array
	typearr = spsh_prstype (obj, nrows, ncols, ctype, spsh_opts);
	if ~(spsh_opts.formulas_as_text)
		# Remove leading '=' from formula strings  //FIXME needs updating
		fptr = ~(4 * (ones (size (typearr))) .- typearr);
		obj(fptr) = cellfun (@(x) x(2:end), obj(fptr), "Uniformoutput", false); 
	endif
	clear fptr

	for ii=1:ncols
		for jj=1:nrows
			try
				# Set value
				sh.getCell(jj+trow-2, ii+lcol-2).setVal (obj{jj, ii});  # Addr.cnt = 0-based
				changed = 1;
			catch
				# Cell not existent. Add cell
				if ~(typearr(jj, ii) == 5)
					sh.add (obj{jj, ii}, jj+trow-2, ii+lcol-2);
					changed = 1;
				endif
			end_try_catch
		endfor
	endfor

	if (changed), xls.changed = max (xls.changed, 1); endif   # Preserve 2 for new files
	rstatus = 1;

endfunction


## Copyright (C) 2011,2012 Philip Nienhuis <prnienhuis@users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## oct2uno2xls

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2011-05-18
## 2011-09-18 Adapted sh_names type to LO 3.4.1
## 2011-09-23 Removed stray debug statements
## 2012-02-25 Fixed wrong var name in L.933
## 2012-02-25 Catch stray Java RuntimeException when deleting sheets
## 2012-02-26 Bug fix when adding sheets near L.994 (wrong if-else-end construct).
## 2012-02-27 Copyright strings updated
## 2012-05-21 "Double" cast added when writing numeric values
## 2012-05-21 "Double" cast moved into main func oct2xls

function [ xls, rstatus ] = oct2uno2xls (c_arr, xls, wsh, crange, spsh_opts)

  changed = 0;
  newsh = 0;
  ctype = [1, 2, 3, 4, 5];  # Float, Logical, String, Formula, Empty

  # Get handle to sheet, create a new one if needed
  sheets = xls.workbook.getSheets ();
  sh_names = sheets.getElementNames ();
  if (! iscell (sh_names))
    # Java array (LibreOffice 3.4.+); convert to cellstr
    sh_names = char (sh_names);
  else
    sh_names = {sh_names};
  endif

  # Clear default 2 last sheets in case of a new spreadsheet file
  if (xls.changed > 2)
    ii = numel (sh_names);
    while (ii > 1)
      shnm = sh_names{ii};
      try
        # Catch harmless Java RuntimeException "out of range" in LibreOffice 3.5rc1
        sheets.removeByName (shnm);
      end_try_catch
      --ii;
    endwhile
    # Give remaining sheet a name
    unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.sheet.XSpreadsheet');
    sh = sheets.getByName (sh_names{1}).getObject.queryInterface (unotmp);
    if (isnumeric (wsh)); wsh = sprintf ("Sheet%d", wsh); endif
    unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.container.XNamed');
    sh.queryInterface (unotmp).setName (wsh);
  else

    # Check sheet pointer
    # FIXME sheet capacity check needed
    if (isnumeric (wsh))
      if (wsh < 1)
        error ("Illegal sheet index: %d", wsh);
      elseif (wsh > numel (sh_names))
        # New sheet to be added. First create sheet name but check if it already exists
        shname = sprintf ("Sheet%d", numel (sh_names) + 1);
        jj = strmatch (wsh, sh_names);
        if (~isempty (jj))
          # New sheet name already in file, try to create a unique & reasonable one
          ii = 1; filler = ''; maxtry = 5;
          while (ii <= maxtry)
            shname = sprintf ("Sheet%s%d", [filler "_"], numel (sh_names + 1));
            if (isempty (strmatch (wsh, sh_names)))
              ii = 10;
            else
              ++ii;
            endif
          endwhile
          if (ii > maxtry + 1)
            error ("Could not add sheet with a unique name to file %s");
          endif
        endif
        wsh = shname;
        newsh = 1;
      else
        # turn wsh index into the associated sheet name
        wsh = sh_names (wsh);
      endif
    else
      # wsh is a sheet name. See if it exists already
      if (isempty (strmatch (wsh, sh_names)))
        # Not found. New sheet to be added
        newsh = 1;
      endif
    endif
    if (newsh)
      # Add a new sheet. Sheet index MUST be a Java Short object
      shptr = java_new ("java.lang.Short", sprintf ("%d", numel (sh_names) + 1));
      sh = sheets.insertNewByName (wsh, shptr);
    endif
    # At this point we have a valid sheet name. Use it to get a sheet handle
    unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.sheet.XSpreadsheet');
    sh = sheets.getByName (wsh).getObject.queryInterface (unotmp);
  endif

  # Check size of data array & range / capacity of worksheet & prepare vars
  [nr, nc] = size (c_arr);
  [topleft, nrows, ncols, trow, lcol] = spsh_chkrange (crange, nr, nc, xls.xtype, xls.filename);
  --trow; --lcol;                      # Zero-based row # & col #
  if (nrows < nr || ncols < nc)
    warning ("Array truncated to fit in range");
    c_arr = c_arr(1:nrows, 1:ncols);
  endif
	
  # Parse data array, setup typarr and throw out NaNs  to speed up writing;
  typearr = spsh_prstype (c_arr, nrows, ncols, ctype, spsh_opts, 0);
  if ~(spsh_opts.formulas_as_text)
    # Find formulas (designated by a string starting with "=" and ending in ")")
    fptr = cellfun (@(x) ischar (x) && strncmp (x, "=", 1), c_arr);
    typearr(fptr) = ctype(4);          # FORMULA
  endif

  # Transfer data to sheet
  for ii=1:nrows
    for jj=1:ncols
      try
        XCell = sh.getCellByPosition (lcol+jj-1, trow+ii-1);
        switch typearr(ii, jj)
          case 1	# Float
            XCell.setValue (c_arr{ii, jj});
          case 2	# Logical. Convert to float as OOo has no Boolean type
            XCell.setValue (double (c_arr{ii, jj}));
          case 3	# String
            unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.text.XText');
            XCell.queryInterface (unotmp).setString (c_arr{ii, jj});
          case 4	# Formula
            if (spsh_opts.formulas_as_text)
              unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.text.XText');
              XCell.queryInterface (unotmp).setString (c_arr{ii, jj});
            else
              XCell.setFormula (c_arr{ii, jj});
            endif
          otherwise
            # Empty cell
        endswitch
		    changed = 1;
      catch
        printf ("Error writing cell %s (typearr() = %d)\n", calccelladdress(trow+ii, lcol+jj), typearr(ii, jj));
		  end_try_catch
    endfor
  endfor

  if (changed)	
    xls.changed = max (min (xls.changed, 2), changed);	# Preserve 2 (new file), 1 (existing)
    rstatus = 1;
  endif

endfunction
