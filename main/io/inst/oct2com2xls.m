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
## Last updated 2009-12-11

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
	obj2 = cell (size (obj));
	txtptr = cellfun ('isclass', obj, 'char');
	if (any(txtptr)) obj2{txtptr} = obj{txtptr}; obj{txtptr} = 0; endif
	eptr = cellfun ('isempty', obj); 
	if (any (eptr)) obj{eptr} = 0; endif
	lptr = cellfun ("islogical" , obj);
	if (any (lptr)) obj2{lptr} = obj{lptr}; obj{lptr} = 0; endif

	ptr = cellfun ("isnan", obj);
	if (any (ptr)) obj{ptr} = []; endif

	# Restore text & booleans
	if (any (txtptr)) obj{txtptr} = obj2{txtptr}; endif
	if (any (lptr)) obj{lptr} = obj2{lptr}; endif
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