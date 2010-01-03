## Copyright (C) 2009 Philip Nienhuis <pr.nienhuis at users.sf.net>
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
## @deftypefn {Function File} [@var{filetype}] = xlsfinfo (@var{filename} [, @var{reqintf}])
## @deftypefnx {Function File} [@var{filetype}, @var{sh_names}] = xlsfinfo (@var{filename} [, @var{reqintf}])
## @deftypefnx {Function File} [@var{filetype}, @var{sh_names}, @var{fformat}] = xlsfinfo (@var{filename} [, @var{reqintf}])
## Query Excel spreadsheet file @var{filename} for some info about its
## contents.
##
## If @var{filename} is a recognizable Excel spreadsheet file,
## @var{filetype} returns the string "Microsoft Excel Spreadsheet", or
## @'' (empty string) otherwise.
## 
## If @var{filename} is a recognizable Excel spreadsheet file, optional
## argument @var{sh_names} contains a list (cell array) of sheet
## names (and in case Excel is installed: sheet types) contained in
## @var{filename}, in the order (from left to right) in which they occur
## in the sheet stack.
##
## Optional return value @var{fformat} currently returns @'' (empty
## string) unless @var{filename} is a readable Excel 95-2003 .xls file in
## which case @var{fformat} is set to "xlWorkbookNormal".
##
## If no return arguments are specified the sheet names are echoed to the 
## terminal screen.
##
## If multiple xls interfaces have been installed @var{reqintf} can be
## specified. This can sometimes be handy to get an idea of used cell ranges
## in each worksheet (the COM/Excel interface can't supply this information).
##
## For use on OOXML spreadsheets one needs full POI support (see xlsopen) and
## 'poi' needs to be specified for @var{reqintf}.
##
## Examples:
##
## @example
##   exist = xlsfinfo ('test4.xls');
##   (Just checks if file test4.xls is a readable Excel file) 
## @end example
##
## @example
##   [exist, names] = xlsfinfo ('test4.xls');
##   (Checks if file test4.xls is a readable Excel file and return a 
##    list of sheet names and -types) 
## @end example
##
## @seealso oct2xls, xlsread, xls2oct, xlswrite
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis@users.sourceforge.net>
## Created: 2009-10-27
## Latest update (echo sheet names to screen, request interface type): 2009-01-01

function [ filetype, sh_names, fformat ] = xlsfinfo (filename, reqintf=[])

	xls = xlsopen (filename, 0, reqintf);
	
	toscreen = nargout < 1;

	xlWorksheet = -4167; xlChart = 4;
	# If any valid xls-pointer struct has been returned, it must be a valid Excel spreadsheet
	filetype = 'Microsoft Excel Spreadsheet'; fformat = '';
	
	if (strcmp (xls.xtype, 'COM'))
		# See if desired worksheet number or name exists
		sh_cnt = xls.workbook.Sheets.count;
		sh_names = cell (sh_cnt, 2);
		ws_cnt = 0; ch_cnt = 0;
		for ii=1:sh_cnt
			sh_names(ii, 1) = xls.workbook.Sheets(ii).Name;
			if (xls.workbook.Sheets(ii).Type == xlWorksheet)
				sh_names(ii, 2) = sprintf ("%5d Worksheet # %d", xlWorksheet, ++ws_cnt);
			elseif (xls.workbook.Sheets(ii).Type == xlChart)
				sh_names(ii, 2) = sprintf ("%5d Chart # %d", xlChart, ++ch_cnt);
			else
				sh_names(ii, 2) = '      Other sheet type';
			endif
		endfor
		if (ws_cnt > 0 || ch_cnt > 0) fformat = "xlWorkbookNormal"; endif
		
	elseif (strcmp (xls.xtype, 'POI'))
		sh_cnt = xls.workbook.getNumberOfSheets();
		sh_names = cell (sh_cnt, 2); nsrows = zeros (sh_cnt, 1);
		for ii=1:sh_cnt
			sh = xls.workbook.getSheetAt (ii-1);         # Java POI starts counting at 0 
			sh_names(ii, 1) = char (sh.getSheetName());
			# Java POI doesn't distinguish between worksheets and graph sheets
			sh_names(ii, 2) = ' ';
			nsrows(ii, 1) = sh.getLastRowNum () + 1;
		endfor
		if (sh_cnt > 0) fformat = "xlWorkbookNormal"; endif

	elseif (strcmp (xls.xtype, 'JXL'))
		sh_cnt = xls.workbook.getNumberOfSheets ();
		sh_names = cell (sh_cnt, 2); nsrows = zeros (sh_cnt, 1);
		sh_names(:,1) = char (xls.workbook.getSheetNames ());
		for ii=1:sh_cnt
			sh_names(ii, 2) = ' ';
			nsrows(ii, 1) = xls.workbook.getSheet(ii-1).getRows ();
		endfor
		if (sh_cnt > 0) fformat = "xlWorkbookNormal"; endif
		
#	elseif     <Other Excel interfaces below>

	else
		error (sprintf ("xlsfinfo: unknown Excel .xls interface - %s.", xls.xtype));

	endif
	if (toscreen)
		# Echo sheet names to screen
		for ii=1:sh_cnt
			str1 = sprintf ("%3d: %s", ii, sh_names{ii, 1});
			if (strcmp (xls.xtype, 'COM'))
				# In case of COM interface, also echo sheet type
				jj = index (sh_names{ii, 2}, '#');
				if (~jj) jj = size (sh_names{ii, 2}, 2); endif
				str2 = sprintf ("   (%s)", sh_names{ii, 2}(6:jj-2) );
			else
				# Other interfaces can supply last row no.
				str2 = sprintf ("   (Last used row # = %d)", nsrows(ii, 1));
			endif
			printf ("%s %s\n", str1, str2);
		endfor
	endif

	xlsclose (xls);
	
endfunction
