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
## Last updated 2009-12-11

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
				otherwise
					# Just skip
			endswitch
		endfor
	endfor
	
	rstatus = 1;
  
endfunction
