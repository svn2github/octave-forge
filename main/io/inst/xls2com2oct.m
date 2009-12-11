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
