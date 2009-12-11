## Copyright (C) 2009 by Philip Nienhuis <prnienhuis at users.sf.net>
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
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
## @deftypefn {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr},  @var{limits}] = xlsread (@var{filename})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = xlsread (@var{filename}, @var{wsh})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = xlsread (@var{filename}, @var{range})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = xlsread (@var{filename}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = xlsread (@var{filename}, @var{wsh}, @var{range}, @var{reqintf})
##
## Read data contained in range @var{range} from worksheet @var{wsh}
## in Excel spreadsheet file @var{filename}.
## Return argument @var{numarr} contains the numeric data, optional
## return arguments @var{txtarr} and @var{rawarr} contain text strings
## and the raw spreadsheet cell data, respectively.
##
## If neither Excel, Java/Apache POI or Java/JExcelAPI are installed,
## xlsread falls back to csv file reading.
##
## In case one of the Java interfaces (Apache POI / JExcelAPI) was
## invoked, @var{limits} contains the outer column/row numbers of the
## spreadsheet range where @var{numarr}, @var{txtarr} and @var{rawarr}
## have come from (remember, xlsread trims outer rows and columns).
##
## If @var{filename} does not contain any directory, the file is
## assumed to be in the current directory.
##
## @var{range} is expected to be a regular spreadsheet range format,
## or "" (empty string, indicating all data in a worksheet).
##
## @var{wsh} is either numerical or text, in the latter case it is 
## case-sensitive and it may be max. 31 characters long.
## Note that in case of a numerical @var{wsh} this number refers to the
## position in the worksheet stack, counted from the left in an Excel
## window. The default is numerical 1, i.e. the leftmost worksheet
## in the Excel file.
##
## If only the first argument is specified, xlsread will try to read
## all contents from the first = leftmost (or the only) worksheet (as
## if a range of @'' (empty string) was specified).
## 
## If only two arguments are specified, xlsread assumes the second
## argument to be @var{range} if it is a string argument and contains 
##  a ":" or if it is @'' (empty string) and in those cases assumes
## the data must be read from the first worksheet (not necessarily
## Sheet1! but the leftmost sheet).
##
## However, if only two arguments are specified and the second argument
## is numeric or a text string that does not contain a ":", it is
## assumed to be @var{wsh} and to refer to a worksheet. In that case
## xlsread tries to read all data contained in that worksheet.
##
## The optional last argument @var{reqintf} can be used to override 
## the automatic selection by xlsread of one interface out of the
## supported ones: COM/Excel, Java/Apache POI, or Java/JExcelAPI.
##
## Erroneous data and empty cells are set to NaN in @var{numarr} and
## turn up empty in @var{txtarr} and @var{rawarr}. Date/time values in
## Excel are returned as numerical values in @var{obj}. Note that
## Excel and Octave have different date base values (1/1/1900 & 
## 1/1/0000, resp.)
## @var{numarr} and @var{txtarr} are trimmed from empty outer rows
## and columns. Be aware that Excel does the same for @var{rawarr}, 
## so any returned array may turn out to be smaller than requested in
## @var{range}.
##
## When reading from merged cells, all array elements NOT corresponding 
## to the leftmost or upper Excel cell will be treated as if the
## "corresponding" Excel cells are empty.
##
## xlsread is just a wrapper for a collection of scripts that find out
## the interface to be used (COM, Java/POI,Java/JXL) and do the actual
## reading. For each call to xlsread the interface must be started and
## the Excel file read into memory. When reading multiple ranges (in
## optionally multiple worksheets) a significant speed boost can be
## obtained by invoking those scripts directly (xlsopen /xls2oct / ...
## / xlsclose [/ parsecell]).
##
## Beware: when using the COM interface, hidden Excel invocations may be
## kept running silently if not closed explicitly.
##
## Examples:
##
## @example
##   A = xlsread ('test4.xls', '2nd_sheet', 'C3:AB40');
##   (which returns the numeric contents in range C3:AB40 in worksheet
##   '2nd_sheet' from file test4.xls into numeric array A) 
## @end example
##
## @example
##   [An, Tn, Ra, status] = xlsread ('Sales2009.xls', 'Third_sheet');
##   (which returns the numeric contents in range C3:AB40 in worksheet
##   'Third_sheet' in file test4.xls into array An, the text data into
##   array Tn, the raw cell data into cell array Ra and the return status
##   in status)
## @end example
##
## @seealso xlswrite, xlsopen, xls2oct, xlsclose, xlsfinfo, oct2xls
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-10-16
## Latest update: 2009-12-11

function [ numarr, txtarr, rawarr, limits ] = xlsread (fn, wsh, datrange, reqintf=[])

rstatus = 0;

if (nargin < 1) 
	error ("xlsread: no arguments specified") 
	numarr = []; txtarr={}; rawarr = {};
	return
elseif (nargin == 1)
	wsh = 1;
	datrange = ''; 
elseif (nargin == 2)
	# Find out whether 2nd argument = worksheet or range
	if (isnumeric (wsh) || (isempty (findstr(wsh,':')) && ~isempty (wsh)))
		# Apparently a worksheet specified
		datrange = '';
	else
		# Range specified
		datrange = wsh;
		wsh = 1;
	endif
endif

# A small gesture for Matlab compatibility. JExcelAPI supports BIFF5.
if (~isempty (reqintf) && strcmp (toupper(reqintf), 'BASIC')) 
	reqintf= "JXL"; 
	printf ("BASIC (BIFF5) support request translated to JXL. \n");
endif

# Checks done. Get raw data into cell array "rawarr". xlsopen finds out
# what interface to use. If none found, suggest csv

# Get pointer array to Excel file
xls = xlsopen (fn, 0, reqintf);

if (strcmp (xls.xtype, 'COM') || strcmp (xls.xtype, 'POI') || strcmp (xls.xtype, 'JXL'))

	# Get data from Excel file & return handle
	[rawarr, xls, rstatus] = xls2oct (xls, wsh, datrange);
	
	# Save some results before xls is wiped
	rawlimits = xls.limits;
	xtype = xls.xtype;
	
	# Close Excel file
	xls = xlsclose (xls);

	if (rstatus)
		[numarr, txtarr, lims] = parsecell (rawarr); 
		limits  = [];
		
		# Rebase various limits to original spreadsheet limits
		if ((strcmp (xtype, 'POI') || strcmp (xtype, 'JXL')) && ~isempty (rawlimits))
			correction = [1; 1];
			if (~isempty(lims.numlimits))
				limits.numlimits(:,1) = rawlimits(:,1) + lims.numlimits(:,1) - correction(:);
				limits.numlimits(:,2) = limits.numlimits(:,1) + lims.numlimits(:,2) - lims.numlimits(:,1);
			endif
			if (~isempty(lims.txtlimits))
				limits.txtlimits(:,1) = rawlimits(:,1) + lims.txtlimits(:,1) - correction(:);
				limits.txtlimits(:,2) = limits.txtlimits(:,1) + lims.txtlimits(:,2) - lims.txtlimits(:,1);
			endif
			limits.rawlimits = rawlimits;
		endif
	else
		rawarr = {}; numarr = []; txtarr = {};
	endif

else
        printf ("\n Error XLSREAD: reading EXCEL .xls file (BIFF-Format) isn\'t supported on this system.\n You need to convert the file into a tab- or comma delimited text file or .csv file\n and then invoke dlmread()\n\n");

endif

endfunction
